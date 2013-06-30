#!/bin/perl

# creates an Morse code image from text
require "/usr/local/lib/bclib.pl";

$height = 48;
$width = 48;

$test = `morse -s < /home/barrycarter/20130626/morse-msg.txt`;
$test=~s/\s+/ /isg;
$test=trim($test);

# header
print << "MARK";
new
size $width,$height
setpixel 0,0,255,255,255
MARK
;

($x,$y) = (0,0);

for $i (split(/ /,$test)) {
  # number of pixels required for this word = 3 for dash, 2 for dot incl space
  my($chars) = ($i=~tr/.//)*2 + ($i=~tr/-//)*3;
  # enough chars left on this line? ($x+1 since we start count at 0)
  if ($chars+$x+1 > $width) {$x=0; $y+=2;}
  # TODO: if $width < $chars, no hope, should check for that
  for $j (split(//,$i)) {
    if ($j eq ".") {
    # print the dot and space
      print "setpixel $x,$y,0,0,0\n";
      $x+=2;
    } elsif ($j eq "-") {
    # print the dash and space
      print "setpixel $x,$y,0,0,0\n";
      $x++;
      print "setpixel $x,$y,0,0,0\n";
      $x+=2;
    } else {
      warn "BAD CHARACTER IN WORDS: $j";
    }
  }

  # "print" space separating words
  $x+=2;
}

