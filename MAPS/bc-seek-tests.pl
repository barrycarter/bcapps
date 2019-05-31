#!/bin/perl

# how fast is seeking within a squashfs file?

require "/usr/local/lib/bclib.pl";

my($buf);

open(A, "/tmp/mnt/climate.bin");

# TODO: generalize

sub latlng2byte {

  my($lat, $lng) = @_;

  # this file happens to be 43200 x 21600 and thus 30 seconds per pixel

  my($x) = floor(($lng+180)*43200/360);
  my($y) = floor((90-$lat)*21600/180);

  return 43200*$y + $x;
}

# the whole world in 256 x 128 px (to compare w/ gdalwarp and gdal_translate

for ($lat=90; $lat>-90; $lat -= 180/128) {
  $row++; $col=0;
  for ($lng=-180; $lng<180; $lng += 360/256) {
    $col++;
    my($byte) = latlng2byte($lat,$lng);

    sysseek(A, $byte, SEEK_SET);
    sysread(A, $buf, 1);
    print $buf;
  }
}
