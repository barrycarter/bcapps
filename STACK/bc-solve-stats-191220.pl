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

# look at diffs

for $i (1..$#x) {
  my($xdiff) = $x[$i]-$x[$i-1];
  my($ydiff) = $y[$i]-$y[$i-1];
  my($dist2) = $xdiff**2+$ydiff**2;
  print "$dist2\n";
}

die "TESTING";

# this lets us look at a few points at a time
@x = @x[0..50];
@y = @y[0..50];

my($minx,$maxx,$miny,$maxy) = (min(@x),max(@x),min(@y),max(@y));

for $i (0..$#x) {
  my($px) = ($x[$i]-$minx)/($maxx-$minx);
  my($py) = ($y[$i]-$miny)/($maxy-$miny);
  my($qx) = $px*600;
  my($qy) = $py*600;
  print "string 255,0,0,$qx,$qy,tiny,$i\n";
}
