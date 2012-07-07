#!/bin/perl

# text browser for OSM (openstreetmap.org)

require "/usr/local/lib/bclib.pl";

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

# peturb the start point for testing
# warn("JFF");
# $user{lat}+=rand()*.02-.01;
# $user{lon}+=rand()*.02-.01;

# get OSM data for 3x3 .01^2 degrees around user
# TODO: remove dupes (should only happen w ways)
for $i (-1..1) {
  for $j (-1..1) {
    parse_file(osm_cache_bc($user{lat}+$i*.01, $user{lon}+$j*.01));
  }
}

# user mercator coords
($mercy, $mercx) = to_mercator($user{lat}, $user{lon});

# use slippy map for reference (18 is max, but not always useful)
# $fname = osm_map($user{lat},$user{lon},15);
# $fname2 = osm_map($user{lat},$user{lon},16);
# $fname3 = osm_map($user{lat},$user{lon},17);
# system("xv $fname $fname2 $fname3 &");

# at this latitude, a mercator "unit" in feet is cos(lat)*world circumference
$mercunit = $EARTH_RADIUS*$PI*2*cos($user{lat}*$DEGRAD)*5280;

# we can only guarentee .01 longitude worth of visibility (in feet)
$vis = $mercunit/360/100;

debug("VIS: $vis ft");

# for each node, compute distance/angle from user (+ more)
for $i (keys %node) {
  # ignore unnamed nodes
#  unless ($node{$i}{name}) {next;}

  # convert to mercator
  ($nodey, $nodex) = to_mercator($node{$i}{lat}, $node{$i}{lon});
  # distance (OK to use Pythag since small area); below is in feet
  # rounding to nearest foot
  $node{$i}{dist} = round(sqrt(($nodex-$mercx)**2+($nodey-$mercy)**2)*$mercunit);
  # ignore nodes that are out of visibility range (does this do anything?)
  if ($node{$i}{dist} > $vis) {next;}

  # and direction
  $node{$i}{dir} = atan2($nodey-$mercy,$nodex-$mercx)*$RADDEG;
  debug("node{$i}{dir} -> $node{$i}{$dir}");
  if ($node{$i}{dir}<0) {$node{$i}{dir}+=360;}

  # niceify direction (integer division below)
  $node{$i}{nicedir} = $dirs[$node{$i}{dir}/45];

  # x and y coords of this node on a 800x600 image centered on user
  $node{$i}{x} = 400 + 400*cos($node{$i}{dir}*$DEGRAD);

  # this is for testing only
#  $truedist = gcdist($user{lat},$user{lon},$node{$i}{lat},$node{$i}{lon})*5280;

#  debug($node{$i}{dist}-$truedist);

#  debug("X/Y: $user{lat}, $user{lon}, $node{$i}{lat}, $node{$i}{lon}, $node{$i}{dist}, $truedist");
}

flymap();

die "TESTING";

$nodeprintcount = 0;

for $i (sort {$node{$a}{dist} <=> $node{$b}{dist}} keys %node) {
  if ($node{$i}{name}) {
    print "$node{$i}{name} is $node{$i}{dist} feet to your $node{$i}{nicedir}\n";
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
debug("HERRO!");
  # using global variables, but that's OK, since this is a
  # program-specific subroutine
  for $i (keys %way) {
    debug("X: $way{$i}{nodelist}");
    for $j (@{$way{$i}{nodelist}}) {
      # ignore points outside range
      if ($node{$j}{dist} > $vis) {next;}
      # x/y position based on current location and 800x600 map
      debug("DIST: $node{$j}{dist}/$vis, AN: $node{$j}{dir}");
      my($px) = round(400 + 400*$node{$j}{dist}/$vis*cos($node{$j}{dir}*$DEGRAD));
      my($py) = round(300 + 300*$node{$j}{dist}/$vis*sin($node{$j}{dir}*$DEGRAD));
      debug("PY: $py", 300*$node{$j}{dist}/$vis*sin($node{$j}{dir}*$DEGRAD));
      print A "setpixel $px,$py,255,255,255\n";
#      debug("J: $j");
    }
  }

  close(A);

}
