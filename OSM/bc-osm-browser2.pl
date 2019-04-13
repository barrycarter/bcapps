#!/bin/perl

# text browser for OSM (openstreetmap.org)

# args: lat lon

# uses 30 second grid

require "/usr/local/lib/bclib.pl";

my($lat, $lon) = @ARGV;

# find NESW of bounding box, rounding to nearest 30 seconds

my($lats) = floor($lat*120)/120;
my($lonw) = floor($lon*120)/120;

my($latn) = $lats+1/120;
my($lone) = $lonw+1/120;

my($url) = "https://api.openstreetmap.org/api/0.6/map?bbox=$lonw,$lats,$lone,$latn";


debug("URL: $url");



die "TESTING";

# TODO: move this to bclib.pl

=item osm_cache_bc2

Given the "lower left" (southwest) latitude/longitude and a size
degree box, download data to /var/cache/OSM and return file holding
data, which will be in microdegrees (to avoid issues)

$options currently unused

=cut

sub osm_cache_bc2 {
  my($lat, $lon, $size, $options) = @_;

  # file where I plan to store this
  my($file) = sprintf("osmdata,%06d,%06d,%06d", $lat*10**6, $lon*10**6, $size*10**6);

  debug("FILE: $file");
  return;

  # .2f just to make sure we're rounded to 2 digits
  # $sha is legacy variable name; sha1sum no longer involved
  # NOTE: I had the call to sprintf completely messed up earlier :(
  # The -.005 is for rounding
  # 0.7 added to get rid of 0.6 results
  my($sha) = sprintf("OSM-0.7-%.2f,%.2f",$lat-.005,$lon-.005);

  # is it already cached in memory?
  if ($shared{osm}{$sha}) {return $shared{osm}{$sha};}

  # no splitting into subdirectories
  my($dir) = "/var/cache/OSM/";

  # if file doesn't already exist, get it
  unless (-f "$dir/$sha") {
    my($cmd) = sprintf("curl -o $dir/$sha 'http://api.openstreetmap.org/api/0.6/map/?bbox=%.2f,%.2f,%.2f,%.2f'", $lon-.005, $lat-.005, $lon+.005, $lat+.005);
#    my($cmd) = sprintf("curl -Lo $dir/$sha 'http://api.openstreetmap.org/api/0.7/map/?bbox=%.2f,%.2f,%.2f,%.2f'", $lon-.005, $lat-.005, $lon+.005, $lat+.005);
    debug("CMD: $cmd");
    debug("OUT: $out");
    my($out, $err, $res) = cache_command($cmd);
  }

  debug("Returning cached info");
  $shared{osm}{$sha} = read_file("$dir/$sha");
  return $shared{osm}{$sha};
}






# https://api.openstreetmap.org/api/0.6/map?bbox=11.54,48.14,11.543,48.145

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

# TODO: infinite loop will start here

if ($globopts{peturb}) {
  $user{lat} += rand($globopts{peturb})-.01;
  $user{lon} += rand($globopts{peturb})-.01;
}

# update global vars based on user new position and clear nodes/ways
user_vars(); @nodes=();@ways=();

# the OSM URL
$url = "http://www.openstreetmap.org/?mlat=$user{lat}&mlon=$user{lon}&zoom=15";

# just for now
# system("firefox '$url'");

print "Latitude: $user{lat}, Longitude: $user{lon}, Visibility: $vis feet\n";

# get OSM data for 3x3 .01^2 degrees around user
# TODO: remove dupes (should only happen w ways)

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

# sort by distance
@goodnodes = sort {$a->{dist} <=> $b->{dist}} @goodnodes;

for $i (0..$user{maxnodes}) {
#  print "$goodnodes[$i]->{name} (node $goodnodes[$i]->{id}{value}) is $goodnodes[$i]->{dist} feet to your $goodnodes[$i]->{nicedir} ($goodnodes[$i]->{lat}{value}, $goodnodes[$i]->{lon}{value}) ($goodnodes[$i]->{dir})\n";
  print "$goodnodes[$i]->{name} (node $goodnodes[$i]->{id}{value}) is $goodnodes[$i]->{dist} feet to your $goodnodes[$i]->{nicedir}\n";
}

die "TESTING";

# <h>"sub way" would've gotten me sued<G></h>
# for ways, compute info relative to user
sub relative_way {
  my($wayref) = @_;

  # have we seen this way before?
  my($id) = $wayref->{id}{value};

  if ($way_seen{$id}) {return;}
  $way_seen{$id} = 1;

  # TODO: handle other cases! (are there any?)
  unless (ref($wayref->{tag})=~/array/i) {return;}

  my(@tags) = @{$wayref->{tag}};
  for $i (@tags) {$wayref->{$i->{k}{value}} = $i->{v}{value};}
  unless ($wayref->{name}) {return;}

  my(@nodes) = @{$wayref->{nd}};

  for $i (@nodes) {
    my($nodenum) = $i->{ref}{value};
    debug(unfold($node{$nodenum}));
  }
}

# given a node (hash), add keys for user distance/angle/more
sub relative_node {
  my($noderef) = @_;

  # have we seen this node before?
  my($id) = $noderef->{id}{value};

  if ($node_seen{$id}) {return;}
  $node_seen{$id} = 1;

  # link id to node
  $node{$id} = $noderef;

  # TODO: handle other cases!
  unless (ref($noderef->{tag})=~/array/i) {return;}

  my(@tags) = @{$noderef->{tag}};

  for $i (@tags) {
    $noderef->{$i->{k}{value}} = $i->{v}{value};
  }

  unless ($noderef->{name}) {return;}

  # get lat, lon
  my($lat,$lon) = ($noderef->{lat}{value}, $noderef->{lon}{value});
  # convert to mercator
  my($nodey, $nodex) = to_mercator($lat,$lon);

  # distance to nearest foot (using Pythagorean thm since distance is small)
  my($dist) = round(sqrt(($nodex-$mercx)**2+($nodey-$mercy)**2)*$mercunit);

  # ignore nodes that are out of visibility range (does this do anything?)
  if ($dist > $vis) {return;}

  # "interesting" nodes (have names and within sight range)
  push(@goodnodes, $noderef);

  # and direction
  # in mercator latitude coordinates, larger = south
  my($dir) = atan2($mercy-$nodey,$nodex-$mercx)*$RADDEG;
  if ($dir<0) {$dir+=360;}

  # niceify direction
  my($nicedir) = $dirs[round($dir/45)];

  # assign to node
  $noderef->{dist} = $dist;
  $noderef->{dir} = $dir;
  $noderef->{nicedir} = $nicedir;
}

flymap();

# TODO: vastly improve this
for $i (keys %way) {
 unless ($way{$i}{name}) {next;}
 print "$way{$i}{name} is here!\n";
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

