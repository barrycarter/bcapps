#!/bin/perl

# text browser for OSM (openstreetmap.org)

# args: lat lon

# uses 30 second grid

# fun way to test: $0 --debug `perl -le 'print rand()*180-90,"
# ",rand()*360-180'`

# TODO: draw vertical and horizontal lines to grid world?
# TODO: use OSM tiles in google maps?

require "/usr/local/lib/bclib.pl";

my($lat, $lon) = @ARGV;

# find NESW of bounding box, rounding to nearest 30 seconds

my($lats) = floor($lat*120)/120;
my($lonw) = floor($lon*120)/120;

debug("USING LAT: $lats, LON: $lonw");

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

my(@items) = ();

while ($data=~s%<(node|way)(.*?)>(.*?)</\g1>%%s) {
  push(@items, handle_item($1, $2, $3));
}

debug(@items);

# debug("DATA: $data");

# TODO: do a better job of this extraction

# while ($data=~s/(<tag.*?>)//) {
#   debug("TAG: $1");
# }

# debug("DATA: $data");

# prog specific sub to handle things

sub handle_item {

  my($type, $header, $data) = @_;

  my($origdata) = $data;

  my(%hash);
  while ($data=~s%<tag k="(.*?)" v="(.*?)"/>%%) {

    my($key, $val) = ($1, $2);

    # assign
    $hash{$key} = $val;

    # this is ugly
    if ($key=~/(.*?):.*/) {
      $hash{$1} .= $val;
    }

  }

  # the type of this item
  # https://taginfo.openstreetmap.org/keys for most used keys

  for $i ("amenity", "highway", "office", "shop", "tourism", "tower", 
	  "waterway", "man_made", "railway", "building", "landuse",
	 "leisure", "aeroway", "natural") {
    if ($hash{$i}) {
      $hash{_type} = "$i: $hash{$i}";
      last;
    }
  }

  unless ($hash{_type} || $hash{name}) {debug("IGNORING: $origdata"); return;}

  # TODO: cleanup
  return "$hash{name} ($hash{_type})";
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
