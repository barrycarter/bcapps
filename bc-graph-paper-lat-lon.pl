#!/bin/perl

# creates graph paper using fly

# TODO: allow for arbitrary axes (eg, scatter plots), size, etc; allow
# for unlabelled paper as well

require "/usr/local/lib/bclib.pl";

$lightcolor = "200,200,255";

my($width) = 180*6*2;
my($height) = 180*6;

my($deltax) = 10*6*2;
my($deltay) = 10*6;

print "new\nsize $width,$height\nsetpixel 0,0,255,255,255\n";

# the lighter lines (not sure I actually want these
for ($i=0; $i<=$width; $i+=$deltax/10) {
  print "line 0,$i,1000,$i,$lightcolor\n";
  print "line $i,0,$i,1000,$lightcolor\n";
}

for ($i=0; $i<=$width; $i+=$deltax) {
  if ($i == $width/2) {$color="255,0,0";} else {$color="0,0,255";}
  print "line 0,$i,$height,$i,$color\n";
  print "line $i,0,$i,$height,$color\n";

  # number to print on axes
  my($y) = 90-$i*18/100;
  my($x) = -2*$y;
  print "string 0,0,0,500,$i,large,$y\n";
  print "string 0,0,0,$i,500,large,$x\n";

}


