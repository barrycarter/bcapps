#!/bin/perl

# determined separately
# x range is 13.281027 to 13.370587
# y range is 52.46025 to 52.500595

require "/usr/local/lib/bclib.pl";

# print "new\nsize 600,600\nsetpixel 0,0,0,0,0\n";

while (<>) {
  s/\[(.*?)\, (.*?)\]//||warn("BADLINE: $_");
  push(@x,$1); push(@y,$2);
}

# this lets us look at a few points at a time
@x = @x[0..200];
@y = @y[0..200];

my($minx,$maxx,$miny,$maxy) = (min(@x),max(@x),min(@y),max(@y));

for $i (0..$#x) {
  my($px) = ($x-$minx)/($maxx-$minx);
  my($py) = ($y-$miny)/($maxy-$miny);
  my($qx) = $px*600;
  my($qy) = $py*600;
  print "string 255,0,0,$qx,$qy,tiny,$pt\n";
}
