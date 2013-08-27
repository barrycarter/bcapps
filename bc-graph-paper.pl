#!/bin/perl

# creates graph paper using fly

require "/usr/local/lib/bclib.pl";

$lightcolor = "200,200,255";

print "new\nsize 1000,1000\nsetpixel 0,0,255,255,255\n";

# the lighter lines (not sure I actually want these
for ($i=0; $i<=1000; $i+=10) {
  print "line 0,$i,1000,$i,$lightcolor\n";
  print "line $i,0,$i,1000,$lightcolor\n";
}

for ($i=0; $i<=1000; $i+=100) {
  if ($i == 500) {$color="255,0,0";} else {$color="0,0,255";}
  print "line 0,$i,1000,$i,$color\n";
  print "line $i,0,$i,1000,$color\n";

  # number to print on axes
  my($y) = 5-$i/100;
  my($x) = -$y;
  print "string 0,0,0,500,$i,large,$y\n";
  print "string 0,0,0,$i,500,large,$x\n";

}


