#!/bin/perl

# text browser for OSM (openstreetmap.org)

require "/usr/local/lib/bclib.pl";

# new approach, XML::Bare
use XML::Bare;

# NOTE: this assumes Earth is locally flat and does NOT work for large
# distances

# cardinal directions (0=8=east)
@dirs = ("east", "northeast", "north", "northwest", "west", "southwest",
	 "south", "southeast", "east");

# %user: global hash with user information
# %node: global hash with node information
# %way: global hash with way information

# defaults if user doesn't set them via global options
defaults("lat=35.116&lon=-106.554&maxnodes=20");

# copy global options to %user
# this could copy pointless values, but that's probably ok?
for $i (keys %globopts) {$user{$i} = $globopts{$i};}

# update global vars based on user new position
user_vars();

# get OSM data for 3x3 .01^2 degrees around user
# TODO: remove dupes (should only happen w ways)

@nodes=();@ways=();
for $i (-1..1) {
  for $j (-1..1) {
    # using XML::Bare for speed <h>(not comfort)</h>
    # putting XML::Bare in list context forces parsing
    ($ob) = new XML::Bare(text => osm_cache_bc($user{lat}+$i*.01, $user{lon}+$j*.01));
    # separate into nodes/ways, ignore rest
    push(@nodes, @{$ob->{xml}{osm}{node}});
    push(@ways, @{$ob->{xml}{osm}{way}});
  }
}

for $i (@nodes) {relative_node($i);}
for $i (@ways) {relative_way($i);}



for $i (@nodes) {
  debug("I: $i->{dist}");
}

die "TESTING";

# print closest nodes
# for $i ($node{dist} <=> $node

# sort {$node{$a}{dist} <=> $node{$b}{dist}} keys %node) {
#  if ($node{$i}{name}) {
#    print "$node{$i}{name} is $node{$i}{dist} feet to your $node{$i}{nicedir}\n";
#    $nodeprintcount++;
#  }
#  if ($nodeprintcount >= $user{maxnodes}) {last;}
# }

die "TESTING";

for $i (@nodes) {
#  unless ($i->{name}) {next;}
#  debug("NAME: $i{name}");
  debug("TAGS:",unfold($i->{tag}));
#  debug("I: $i");
}

die "TESTING";

for $i (keys %way) {
  %hash = %{$way{$i}};
  @nodes = $hash{nodes};
  debug("BETA: $hash{name}, $hash{nodes}");
}

die "TESTING";

# debug("ALPHA",%way);

relative_way();

# <h>"sub way" would've gotten me sued<G></h>
# for ways, compute info relative to user

sub relative_way {
  for $i (keys %way) {
    # ignore unnamed ways
    my(%way) = %{$way{$i}};
#    debug("WAY: $way", dump_var($way));
    unless ($way{name}) {next;}
    debug($way{name});
  }
}

die "TESTING";

# given a node (hash), add keys for user distance/angle/more

sub relative_node {
  my($noderef) = @_;

  # TODO: handle other cases!
  unless (ref($noderef->{tag})=~/array/i) {return;}

  my(@tags) = @{$noderef->{tag}};

  for $i (@tags) {
    my(%hash) = %{$i};
    my(%tagkeys) = $hash{k};
    my(%tagvals) = $hash{v};
    debug("KEYS",keys %tagkeys);
    debug("VALS",keys %tagvals);
  }

  # get lat, lon
  my($lat,$lon) = ($noderef->{lat}{value}, $noderef->{lon}{value});
  # convert to mercator
  my($nodey, $nodex) = to_mercator($lat,$lon);

  # distance to nearest foot (using Pythagorean thm since distance is small)
  my($dist) = round(sqrt(($nodex-$mercx)**2+($nodey-$mercy)**2)*$mercunit);

  # ignore nodes that are out of visibility range (does this do anything?)
  if ($dist > $vis) {return;}

  # and direction
  my($dir) = fmod(atan2($nodey-$mercy,$nodex-$mercx),1)*$RADDEG;

  # niceify direction (integer division below)
  my($nicedir) = $dirs[$dir/45];

  # assign to node
  $noderef->{dist} = $dist;
  $noderef->{dir} = $dir;
  $noderef->{nicedir} = $nicedir;
}

flymap();

die "TESTING";

$nodeprintcount = 0;

die "TSETING";

# TODO: vastly improve this
for $i (keys %way) {
 unless ($way{$i}{name}) {next;}
 print "$way{$i}{name} is here!\n";
}

# parses the result of what the API sends us by updating the %node and
# %way hashes. Returns nothing

sub parse_file {
  debug("START PARSE FILE");
  my($data) = @_;
  debug("DATA: $data");
die "TESTING";

  # convert <node .../> to <node ...></node>
  # for speed, ignore nodes w/ no info at least for now
#  $data=~s%<(node[^>]*)/>%<$1></node>%isg;

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

  debug("END PARSE FILE");
}

# construct a PNG map using fly of current nodes/ways
# this is more to help me as I write the program, not really "part" of
# the program

sub flymap {
  # fly commands
  # TODO: use tmpfile or subdir
  open(A,">/tmp/bob-fly.txt");

  print A << "MARK";
new
size 800,600
setpixel 0,0,0,0,0
MARK
;
  # using global variables, but that's OK, since this is a
  # program-specific subroutine
  for $i (keys %way) {
    debug("NAME: $way{$i}{name}");
    debug("X: $way{$i}{nodelist}");
    for $j (@{$way{$i}{nodelist}}) {
      # ignore points outside range
      if ($node{$j}{dist} > $vis) {next;}
      # x/y position based on current location and 800x600 map
      debug("DIST: $node{$j}{dist}/$vis, AN: $node{$j}{dir}");
      my($px) = round(400 + 400*$node{$j}{dist}/$vis*cos($node{$j}{dir}*$DEGRAD));
      my($py) = round(300 + 300*$node{$j}{dist}/$vis*sin($node{$j}{dir}*$DEGRAD));
      debug("PY: $py", 300*$node{$j}{dist}/$vis*sin($node{$j}{dir}*$DEGRAD));

      # single street printing for now
#      unless ($way{$i}{name}=~/(cand|verm|wisc|virg)/i) {next;}

      my($print) = substr($way{$i}{name},0,3);

#      print A "setpixel $px,$py,255,255,255\n";
      print A "string 255,255,255,$px,$py,tiny,$print\n";
#      debug("J: $j");
    }
  }

  close(A);
  system("fly -i /tmp/bob-fly.txt -o /tmp/output.gif && xv /tmp/output.gif");

}

# global vars change based on user location
sub user_vars {
  # user mercator coordinates
  ($mercy, $mercx) = to_mercator($user{lat}, $user{lon});
  # at this latitude, a mercator "unit" in feet is cos(lat)*world circumference
  $mercunit = $EARTH_RADIUS*$PI*2*cos($user{lat}*$DEGRAD)*5280;

  # we can only guarentee .01 longitude worth of visibility (in feet)
  $vis = $mercunit/360/100;
}

