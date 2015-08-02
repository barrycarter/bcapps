#!/bin/perl

# TODO: I probably need to merge OSM and MAPS dirs or move this playground

require "/usr/local/lib/bclib.pl";
use XML::Simple;

# not a real subroutine, just temporary for plotting

# sub latlon2xy {
#  my($lat,$lon,$slat,$nlat,$wlon,$elon,$xwid,$ywid) = @_;
  

print << "MARK";
new
size 600,600
setpixel 0,0,0,0,0
MARK
;

# NOTE: using Data::Dumper does not speed things up much
# use Data::Dumper;

# level 13 = ok, level 12 and lower xapi seems to fail (too much data)
my($file,$slat,$nlat,$wlon,$elon) = slippy2osm(1671,3241,13);

# smaller set for testing only (normally, I'd get this from level 13 tiles)
# my($file,$slat,$nlat,$wlon,$elon) = slippy2osm(106881,207474,19);
debug("$slat/$nlat, $wlon/$elon");
my($xml) = new XML::Simple;
my($data) = $xml->XMLin($file);

for $i (keys %{$data->{way}}) {
#  debug(@{$data->{way}->{$i}->{nd}});
#  next;
  my(@nodes) = @{$data->{way}->{$i}->{nd}};

  # draw from the 1st to last node, looking back (so we do get 0)
  for $j (1..$#nodes) {
    my($node1) = $nodes[$j]->{ref};
    my($node2) = $nodes[$j-1]->{ref};
    debug("$node1/$node2");
  }


  debug("I: $i, NODES:",@nodes);
}

die "TESTING";

for $i (keys %{$data->{node}}) {
  debug("I: $i");
  my($lat,$lon) = ($data->{node}->{$i}->{lat},$data->{node}->{$i}->{lon});

  # ignore outside range (at least for now)
  if ($lat<$slat || $lat>$nlat || $lon<$wlon || $lon>$elon) {next;}

  # going 600x600 for now
  my($y) = ($nlat-$lat)/($nlat-$slat);
  my($x) = ($lon-$wlon)/($elon-$wlon);
  $y*=600;
  $x*=600;
  print "fcircle $x,$y,3,255,255,255\n";
  debug("$lon/$lat $wlon/$elon/$slat/$nlat -> $x/$y")

#  debug("$lat/$lon");
#  debug("I: $i -> $data->{node}{$i}");
}

# doing ways first (or not)

# for $i (keys %{$data->{way}}) {

# debug(var_dump("data",$data));

die "TESTING";

my(%nodes);

# "simple" nodes

while ($data=~s%(<node.*?/>)%%s) {
  my($node) = $1;
  # only id/lat/lon are interesting(?)
  # TODO: could this code be improved?
  my(%temphash);
  while ($node=~s% (id|lat|lon)="(.*?)"%%) {$temphash{$1}=$2;}
  for $i ("lat","lon") {$nodes{$temphash{id}}{$i} = $temphash{$i};}
}

debug(var_dump("nodes",\%nodes));


# given a slippy tile, find nodes/ways on it using OSM server

sub slippy2osm {
  my($x,$y,$z) = @_;
  my($nlat,$wlon) = slippy2latlon($x,$y,$z,0,0);
  my($slat,$elon) = slippy2latlon($x,$y,$z,255,255);
  # xapi seems to do what I need "minimally"
  my($box) = urlencode("*[bbox=$wlon,$slat,$elon,$nlat]");
  my($url) = "http://open.mapquestapi.com/xapi/api/0.6/$box";
  # /var/cache/OSM3 to cache these (OSM[12] for other projects not here)
  # TODO: if parent tile contains all sub info, use it instead?
  my($file) = "/var/cache/OSM3/$z-$x-$y.dat";
  unless (-f $file) {
    my($out,$err,$res) = cache_command("curl -o $file '$url'");
  }

  # TODO: return file and bbox (in case caller didn't compute it)
  return $file, $slat, $nlat, $wlon, $elon;

}
