#!/bin/perl

# creates an Morse code image from text
require "/usr/local/lib/bclib.pl";

$height = 48;
$width = 48;

$test = `morse -s < /home/barrycarter/20130626/morse-msg.txt`;
chomp($test);
debug("TEST: $test");
$test=~s/\s+/ /isg;
$test=trim($test);
debug("TEST: $test");

# header
print << "MARK";
new
size $width,$height
setpixel 0,0,255,255,255
MARK
;

($x,$y) = (0,0);

for $i (split(//,$test)) {
  if ($i eq ".") {
    # print the dot
    print "setpixel $x,$y,0,0,0\n";
  } elsif ($i eq "-") {
    # print the dash
    # dash should not go over edge
    if ($x>$height-1) {$x=0; $y+=2}
    print "setpixel $x,$y,0,0,0\n";
    $x++;
    print "setpixel $x,$y,0,0,0\n";
  } elsif ($i eq " ") {
    # do nothing but accept as valid character
  } else {
    die "BAD CHARCTER: $i";
  }

  # print space advance cursor (if end of line, go to next line)
  $x+=2;
  if ($x>$width) {$x=0; $y+=2;}

}

