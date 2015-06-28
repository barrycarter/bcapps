#!/bin/perl

# uses fly to create a "random" large image that should not be viewed
# directly, but will be cut up into 600x400 dink tilescreens

require "/usr/local/lib/bclib.pl";

print << "MARK";
new
size 19200,9600
setpixel 0,0,255,255,255
MARK
;

for $i (1..100000) {
  my($x) = int(rand()*19200);
  my($y) = int(rand()*9600);
  print "string 0,0,0,$x,$y,giant,this is $x $y\n";
}


