#!/bin/perl

# Trivial script that creates a fly script to add numbers to a Dink
# map (after it's been converted to gif)

require "/usr/local/lib/bclib.pl";

print "existing map.gif\n";

for $i (0..31) {

  # adjust for two digits
  my($x) = $i<10?6:1;
  my($y) = 1+20*$i;

  print "string 255,255,255,$x,$y,giant,$i\n";
  print "string 255,255,255,$y,$x,giant,$i\n";

#  if ($i%5==0) {
    print "dline 0,$y,640,$y,0,0,255\n";
    print "dline $y,0,$y,480,0,0,255\n";
#  }

}
