#!/bin/perl

# how fast is seeking within a squashfs file?

require "/usr/local/lib/bclib.pl";

# an array of random colors

my(@cols, @col);

for $i (0..255) {

  for $j (0..2) {$col[$j] = floor(rand()*256);}

  push(@cols, join(",", @col));
}

# debug(@cols);

print "new\nsize 2048,1024\nsetpixel 0,0,0,0,0\n";


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

# the whole world in 2048 x 1024 pixels

for ($lat=-90; $lat<=90; $lat += 180/1024) {
  $row++; $col=0;
  for ($lng=-180; $lng<=180; $lng += 360/2048) {
    $col++;
    my($byte) = latlng2byte($lat,$lng);

    sysseek(A, $byte, SEEK_SET);
    sysread(A, $buf, 1);

    my($val) = ord($buf);

    print "setpixel $col,$row,$cols[$val]\n";

  }
}
