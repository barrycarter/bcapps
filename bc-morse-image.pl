#!/bin/perl

# creates an Morse code image from text
require "/usr/local/lib/bclib.pl";

$text = "Test #001";

$test="- .  ...  - ----- ----- .---- ...-.-";
$test=~s/\s+/ /isg;

$height = 20;
$width = 200;

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
    print "setpixel $x,$y,0,0,0\n";
    $x++;
    print "setpixel $x,$y,0,0,0\n";
  } elsif ($i eq " ") {
    # do nothing but accept as valid character
  } else {
    die "BAD CHARCTER: $i";
  }

  # print space advance cursor
  $x+=2;
}

