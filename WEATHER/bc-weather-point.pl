#!/bin/perl

# attempts to get weather by point based on openweathermap API

require "/usr/local/lib/bclib.pl";
require "/home/user/bc-private.pl";
require Image::PNG;

my($lat, $lon) = @ARGV;

# find the xyz pos of point
my($posx, $posy, $posz) = sph2xyz($lon, $lat, 1, "degrees=1");

my($z) = 5;
my($x, $y, $px, $py) =  latLonZoom2SlippyTilePixel($lat, $lon, $z);

# obtain weather data

cache_command2("curl -o /var/cache/OWM/conditions.json 'http://api.openweathermap.org/data/2.5/box/city?bbox=-180,-90,180,90,999999&appid=$private{openweathermap}{appid}'", "age=900");

# TODO: subroutinize this

my($data) = JSON::from_json(read_file("/var/cache/OWM/conditions.json"));

# find the closest station
my($mindist) = Infinity;
my($minhash);

for $i (@{$data->{list}}) {
  my($x, $y, $z) = sph2xyz($i->{coord}{Lon}, $i->{coord}{Lat}, 1, "degrees=1");

  my($dist2) = ($x-$posx)**2 + ($y-$posy)**2 + ($z-$posz)**2;

  if ($dist2 < $mindist) {
    $mindist = $dist2;
    $minhash = $i;
  }
}

my($dist) = sprintf("%0.2f", gcdist($lat, $lon, $minhash->{coord}{Lat}, $minhash->{coord}{Lon}));

print "CLOSEST: $minhash->{name} ($minhash->{coord}{Lat}, $minhash->{coord}{Lon}) ($dist miles)\n";
debug(var_dump("MH", $minhash));

# obtain and cache the slippy tiles from openweathermap

for $i ("clouds", "precipitation", "pressure", "wind", "temp") {
  my($cmd) = "curl -o /var/cache/OWM/$i-$z-$x-$y.png 'https://tile.openweathermap.org/map/${i}_new/$z/$x/$y.png?appid=$private{openweathermap}{appid}'";
  cache_command2($cmd, "age=900");

  my(@arr) = readPNG("/var/cache/OWM/$i-$z-$x-$y.png");

  $px = round($px);
  $py = round($py);

  print join("\t", $i, $arr[$px][$py], $px, $py),"\n";

  for $x ($px-1..$px+1) {
    for $y($py-1..$py+1) {
#      print "$i $x $y $arr[$x][$y]\n";
    }
  }
}

=item readPNG($fname)

Read the PNG file $fname and return an array of arrays with its pixel values

=cut

sub readPNG {
  my($fname) = @_;
  my(@res);

  my($png) = Image::PNG->new();
  $png->read($fname);
  my($bytesPerPixel) = $png->rowbytes/$png->width();

  for $i (0..$#{$png->rows}) {
    my($str) = @{$png->rows}[$i];

    for ($j=0; $j < length($str); $j += $bytesPerPixel) {
      my($sub) = substr($str, $j,  $bytesPerPixel);
      # TODO: icky indexing here
      $res[$i][$j/$bytesPerPixel] = join(",",map($_=ord($_), split(//, $sub)));
    }
  }
  return @res;

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


