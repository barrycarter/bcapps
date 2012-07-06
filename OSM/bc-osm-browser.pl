#!/bin/perl

# text browser for OSM (openstreetmap.org)

require "/usr/local/lib/bclib.pl";

# NOTE: this assumes Earth is locally flat and does NOT work for large
# distances

# cardinal directions (0=8=east)
@dirs = ("east", "northeast", "north", "northwest", "west", "southwest",
	 "south", "southeast", "east");

# defaults if user doesn't set them via global options
defaults("lat=35.116&lon=-106.554&maxnodes=20");

# copy global options to %user
# this could copy pointless values, but that's probably ok?
for $i (keys %globopts) {$user{$i} = $globopts{$i};}

# %user: global hash with user information
# %node: global hash with node information
# %way: global hash with way information

# get OSM data for 3x3 .01^2 degrees around user
# TODO: remove dupes (should only happen w ways)
for $i (-1..1) {
  for $j (-1..1) {
    parse_file(osm_cache_bc($user{lat}+$i*.01, $user{lon}+$j*.01));
  }
}

# figure out max visibility (limited by longitude)
$maxvis = $EARTH_RADIUS*$PI*2*.01/360*cos($user{lat}*$DEGRAD);
debug("VIS: $maxvis");

# for each node, add distance and direction (from user)
for $i (keys %node) {
  # calculate *approximate* N/S and E/W distance in miles

  # N/S dist is constant
  $nsdist = ($node{$i}{lat}-$user{lat})*$EARTH_RADIUS*2*$PI/360;

  # E/W distance is scaled by cos(lat)
  $ewdist = ($node{$i}{lon}-$user{lon})*$EARTH_RADIUS*2*$PI/360*cos($user{lat}*$DEGRAD);

  # direction and total dist (Pythag ok for small distances)
  $node{$i}{dir} = atan2($nsdist,$ewdist)*$RADDEG;
  $node{$i}{dist} = sqrt($nsdist*$nsdist+$ewdist*$ewdist);

  # cardinal direction (to nearest 22.5 degrees)
  if ($node{$i}{dir}<0) {$node{$i}{dir}+=360};

  $card = round($node{$i}{dir}/45);
  $node{$i}{nicedir} = $dirs[$card];

  # for printing...
  $node{$i}{nicedist} = sprintf("%d feet",$node{$i}{dist}*5280);
}

# print closest "20" nodes
$nodeprintcount = 0;

for $i (sort {$node{$a}{dist} <=> $node{$b}{dist}} keys %node) {
  if ($node{$i}{name}) {
    print "$node{$i}{name} is $node{$i}{nicedist} to your $node{$i}{nicedir}\n";
    $nodeprintcount++;
  }
  if ($nodeprintcount >= $user{maxnodes}) {last;}
}

die "TSETING";

# TODO: vastly improve this
for $i (keys %way) {
 unless ($way{$i}{name}) {next;}
 print "$way{$i}{name} is here!\n";
}

# parses the result of what the API sends us by updating the %node and
# %way hashes. Returns nothing

sub parse_file {
  my($data) = @_;

  # convert <node .../> to <node ...></node>
  $data=~s%<(node[^>]*)/>%<$1></node>%isg;

  # handle nodes
  while ($data=~s%<node(.*?)>(.*?)</node>%%s) {
    my($head, $tags) = ($1, $2);

    # store node data in hash
    my(%thisnode) = ();

    # values in tag itself
    while ($head=~s/(\S+)\=\"(.*?)\"//) {$thisnode{$1} = $2;}

    # tag values
    while ($tags=~s%<tag k="(.*?)" v="(.*?)"/>%%s) {$thisnode{$1} = $2;}

    # update the global node hash
    $node{$thisnode{id}} = {%thisnode};
  }

  # <h>ooh, baby I love your</h> ways
  while ($data=~s%<way(.*?)>(.*?)</way>%%is) {
    my($head, $tags) = ($1, $2);

    #<h>The following line of code is in tribute to Frank Sinatra</h>
    my(%thisway) = ();
    # list of nodes for this way
    my(@nodelist);

    # values in tag itself
    while ($head=~s/(\S+)\=\"(.*?)\"//) {$thisway{$1} = $2;}

    # tag values
    while ($tags=~s%<tag k="(.*?)" v="(.*?)"/>%%s) {$thisway{$1} = $2;}

    # nodes in way
    while ($tags=~s%<nd ref="(.*?)"/>%%) {push(@nodelist,$1);}
    
    $thisway{nodelist} = [@nodelist];

    $way{$thisway{id}} = {%thisway};

  }
}
