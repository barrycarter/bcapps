#!/bin/perl

# text browser for OSM (openstreetmap.org)

require "/usr/local/lib/bclib.pl";

get_osm(35,-106);
get_osm(35.01,-105.99);

=item get_osm($lat, $lon)

Obtain AND cache (important!) the OSM data for the .01 degree box
whose lower left corner is $lat, $lon

$lat and $lon are truncated to 2 decimal places for caching

=cut

sub get_osm {
  my($lat, $lon) = @_;
  $lat = sprintf("%.2f", $lat);
  $lon = sprintf("%.2f", $lon);

  # upper right corner of box (using sprintf to avoid roundoff issues)
  my($ulat) = sprintf("%.2f", $lat+.01);
  my($ulat) = sprintf("%.2f", $lat+.01);

  # where to store this
  my($sha) = sha1_hex("$lat,$lon");

  # .01 degree tiles -> 360*100*180*100 = ~648M tiles total, so
  # splitting into dirs
  $sha=~m%^(..)(..)%;
  my($dir) = "/var/tmp/OSM/cache/$1/$2/";

  # does it already exist?
  if (-f "$dir/$sha") {return read_file("$dir/$sha");}

  # TODO: test that below works
  system("mkdir -p $dir");

  # and get the data


  debug("SHA: $sha");
}

