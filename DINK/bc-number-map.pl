#!/bin/perl

# Trivial script that creates a fly script to add numbers to a Dink
# map (after it's been converted to gif)

require "/usr/local/lib/bclib.pl";

print "existing map.gif\n";

for $i (0..31) {

  my($pos) = $i*20;

  # adjust for two digits
  my($x) = $i<10?8:6;
  my($y) = 6+$pos;
  my($y2) = $i<10?$y+2:$y;

  print "string 255,255,255,$x,$y,tiny,$i\n";
  print "string 255,255,255,$y2,6,tiny,$i\n";

#  if ($i%5==0) {
    print "dline 0,$pos,640,$pos,0,0,255\n";
    print "dline $pos,0,$pos,480,0,0,255\n";
#  }

}
