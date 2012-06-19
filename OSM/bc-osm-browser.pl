#!/bin/perl

# text browser for OSM (openstreetmap.org)

# NOTE: this assumes Earth is locally flat and does NOT work for large distances

# %user: global hash with user information
# %node: global hash with node information
# %way: global hash with way information

require "/usr/local/lib/bclib.pl";

# TODO: let user set these
$user{lat} = 35.116;
$user{lon} = -106.554;

# get OSM data for 3x3 .01^2 degrees around user
# TODO: remove dupes (should only happen w ways)
for $i (-1..1) {
  for $j (-1..1) {
    parse_file(get_osm($user{lat}+$i*.01, $user{lon}+$j*.01));
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
}

for $i (sort {$node{$a}{dist} <=> $node{$b}{dist}} keys %node) {
  if ($node{$i}{name}) {
    print "$node{$i}{name} at $node{$i}{dist}, $node{$i}{dir}; $node{$i}{lat}, $node{$i}{lon}\n";
  }
}

# TODO: vastly improve this
for $i (keys %way) {
 unless ($way{$i}{name}) {next;}
 print "$way{$i}{name} is here!\n";
}

=item get_osm($lat, $lon)

Obtain AND cache (important!) the OSM data for the .01 degree box
whose lower left corner is $lat, $lon

$lat and $lon are truncated to 2 decimal places for caching

=cut

sub get_osm {
  my($lat, $lon) = @_;
  $lat = sprintf("%.2f", $lat);
  $lon = sprintf("%.2f", $lon);

  # where to store this
  my($sha) = sha1_hex("$lat,$lon");

  # .01 degree tiles -> 360*100*180*100 = ~648M tiles total, so
  # splitting into dirs
  $sha=~m%^(..)(..)%;
  my($dir) = "/var/tmp/OSM/cache/$1/$2";

  # does it already exist?
  if (-f "$dir/$sha") {return read_file("$dir/$sha");}

  # TODO: test that below works
  system("mkdir -p $dir");

  # and get the data
  # TODO: handle "too much data" case
 my($cmd) = sprintf("curl -o $dir/$sha 'http://api.openstreetmap.org/api/0.6/map/?bbox=%.2f,%.2f,%.2f,%.2f'", $lon, $lat, $lon+.01, $lat+.01);

  my($out, $err, $res) = cache_command($cmd);
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
