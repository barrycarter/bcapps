#!/bin/perl

# determined separately
# x range is 13.281027 to 13.370587
# y range is 52.46025 to 52.500595

require "/usr/local/lib/bclib.pl";

print "new\nsize 600,600\nsetpixel 0,0,0,0,0\n";

while (<>) {
  s/\[(.*?)\, (.*?)\]//||warn("BADLINE: $_");
  my($x,$y) = ($1,$2);

  my($px) = ($x-13.281027)/(13.370587-13.281027);
  my($py) = ($y-52.46025)/(52.500595-52.46025);

  my($qx) = $px*600;
  my($qy) = $py*600;

  $pt++;

#  print "setpixel $qx,$qy,255,0,0\n";
  print "string 255,0,0,$qx,$qy,tiny,$pt\n";

}
