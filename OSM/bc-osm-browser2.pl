#!/bin/perl

# text browser for OSM (openstreetmap.org)

# args: lat lon

# uses 30 second grid

require "/usr/local/lib/bclib.pl";

my($lat, $lon) = @ARGV;

# find NESW of bounding box, rounding to nearest 30 seconds

my($lats) = floor($lat*120)/120;
my($lonw) = floor($lon*120)/120;

my($fname) = osm_cache_bc2($lats, $lonw, 1/120);

my($data) = read_file($fname);

# TODO: better job of ignoring unnecessary

# ignore self-closing nodes
$data=~s%<node.*?/>%%g;

# ignore nd refs inside ways
$data=~s%<nd ref="\d+"/>%%g;

# cleanup blanks
$data=~s/\s*\n+\s*/\n/sg;

# handle nodes and ways

while ($data=~s%<(node|way)(.*?)>(.*?)</\g1>%%s) {handle_item($1, $2, $3);}

# debug("DATA: $data");

# TODO: do a better job of this extraction

# while ($data=~s/(<tag.*?>)//) {
#   debug("TAG: $1");
# }

# debug("DATA: $data");

# prog specific sub to handle things

sub handle_item {

  my($type, $header, $data) = @_;

  my(%hash);
  while ($data=~s%<tag k="(.*?)" v="(.*?)"/>%%) {$hash{$1} = $2;}

  unless ($hash{amenity} || $hash{name}) {return;}

  # TODO: cleanup
  return "$hash{name} ($hash{amenity})";
}


# TODO: move this to bclib.pl

=item osm_cache_bc2

Given the "lower left" (southwest) latitude/longitude and a size
degree box, download data to /var/cache/OSM and return file holding
data

$options currently unused

=cut

sub osm_cache_bc2 {
  my($lats, $lonw, $size, $options) = @_;

  # file where I plan to store this
  my($file) = sprintf("/var/cache/OSM/osmdata,%f,%f,%f", $lats, $lonw, $size);

  # if it exists, return it
  if (-f $file) {return $file;}

  # if not, pull data
  my($url) = sprintf("https://api.openstreetmap.org/api/0.6/map?bbox=%f,%f,%f,%f", $lonw, $lats, $lonw+$size, $lats+$size);
  cache_command2("curl -o $file '$url'");
  return $file;
}
