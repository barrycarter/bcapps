#!/bin/perl

# TODO: I probably need to merge OSM and MAPS dirs or move this playground

require "/usr/local/lib/bclib.pl";
use XML::Simple;

# slippy2osm(106881,207474,19);
# level 13 = ok, level 12 and lower xapi seems to fail (too much data)
my($data) = read_file(slippy2osm(1671,3241,13));
# my($file) = slippy2osm(1671,3241,13);
# my($xml) = new XML::Simple;
# my($data) = $xml->XMLin($file);
# debug(var_dump("data",$data));
# die "TESTING";

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

  # TODO: return something more useful?
  return $file;

}
