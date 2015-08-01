#!/bin/perl

require "/usr/local/lib/bclib.pl";

slippy2osm(106881,207474,19);

# given a slippy tile, find nodes/ways on it using OSM server

sub slippy2osm {
  my($x,$y,$z) = @_;
  my($nlat,$wlon) = slippy2latlon($x,$y,$z,0,0);
  my($slat,$elon) = slippy2latlon($x,$y,$z,255,255);
  my($url) = "http://open.mapquestapi.com/xapi/api/0.6/*[bbox=$wlon,$slat,$elon,$nlat]";
  # TODO: probably have a subroutine for the two lines below
  $url=~s/\[/%5B/g;
  $url=~s/\]/%5D/g;

  # overpass might be better
  $url = "http://overpass-api.de/api/interpreter?data=(node($slat,$wlon,$nlat,$elon);<;);out;";

  # or google maps? (TODO: use mlat and mlon, not s/n e/w)
  $url = "https://maps.googleapis.com/maps/api/streetview?location=$slat,$wlon&size=620x400";

  debug("URL: $url");

}
