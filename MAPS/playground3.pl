#!/bin/perl

require "/usr/local/lib/bclib.pl";

slippy2osm(13356,25934,16);

# given a slippy tile, find nodes/ways on it using OSM server

sub slippy2osm {
  my($x,$y,$z) = @_;
  my($nlat,$wlon) = slippy2latlon($x,$y,$z,0,0);
  my($slat,$elon) = slippy2latlon($x,$y,$z,255,255);
  my($url) = sprintf("http://api.openstreetmap.org/api/0.6/map/?bbox=%f,%f,%f,%f", $wlon, $slat, $elon, $nlat);
  debug("$url");
}

  
