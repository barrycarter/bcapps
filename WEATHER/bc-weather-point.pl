#!/bin/perl

# attempts to get weather by point based on openweathermap API

require "/usr/local/lib/bclib.pl";
require "/home/user/bc-private.pl";
require Image::PNG;

my($z) = 5;
my($x, $y, $px, $py) =  latLonZoom2SlippyTilePixel(35.05, -106.5, $z);
my $png = Image::PNG->new();


# obtain and cache the slippy tiles from openweathermap

for $i ("clouds_new", "precipitation_new", "pressure_new", "wind_new", "temp_new") {
  my($cmd) = "curl -o /var/cache/OWM/$i-$z-$x-$y.png 'https://tile.openweathermap.org/map/$i/$z/$x/$y.png?appid=$private{openweathermap}{appid}'";
  cache_command2($cmd, "age=900");
  $png->read("/var/cache/OWM/$i-$z-$x-$y.png");
  debug($png->data());
}

=item latLonZoom2SlippyTilePixel($lat, $lon, $zoom, $options)

Determine the slippy tile at level $zoom that contains $lat, $lon, and
the pixel value where $lat, $lon falls in that tile

=cut

sub latLonZoom2SlippyTilePixel {
  my($lat, $lon, $zoom, $options) = @_;
  my(%opts) = parse_form($options);
  my($x,$y,$px,$py);

  # convert to mercator
  ($y,$x) = to_mercator($lat, $lon);

  # figure out where in map $lat/$lon occurs
  ($x,$y) = ($x*2**$zoom, $y*2**$zoom);

  # for now, intentionally not rounding
  ($px, $py) = (($x-int($x))*256, ($y-int($y))*256);

  # use zoom to figure out canonical name
  $y = floor($y);
  $x= floor($x);

  return $x, $y, $px, $py;
}


