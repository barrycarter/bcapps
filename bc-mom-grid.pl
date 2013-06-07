#!/bin/perl

# Uses fly to draw a transparent overly grid to help play Masters of
# Magic (in a window about 1000 pixels wide, or any consistent size--
# can be used for many other purposes too); overlay grid when using F2
# mode in Masters of Magic

require "/usr/local/lib/bclib.pl";

$str = "new\nsize 1000,1000\nsetpixel 0,0,255,255,255\n";

for $i (0..10) {
  $x = $i*100;
  $str .= "line 0,$x,1000,$x,0,0,0\n";
  $str .= "line $x,0,$x,1000,0,0,0\n";
  for $j (0..10) {
    $y = $j*100;
    $xp = $x+2;
    $str .= "string 0,0,0,$xp,$y,small,$x,$y\n";
  }
}

write_file($str,"/tmp/bcmomgrid.fly");
system("fly -q -i /tmp/bcmomgrid.fly -o /tmp/bcmomgrid.gif");
system("convert -transparent white /tmp/bcmomgrid.gif /tmp/bcmomgridfinal.gif");
system("xteddy -F/tmp/bcmomgridfinal.gif");


