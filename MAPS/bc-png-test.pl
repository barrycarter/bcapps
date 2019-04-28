#!/bin/perl

# Since I have all of my data in map files anyway, why not just read
# the tiny PNGs (one reason: for things like elevation, I might use
# the same color for multiple values)

use Image::PNG;
require "/usr/local/lib/bclib.pl";

# one of the climate 256x256 files (this is actually the biggest one)

my($png) = "/home/user/BCGIT/BCINFO3/sites/test/BECK2/256/beck_kg_256_4345.png";

debug(readPNG($png));

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

