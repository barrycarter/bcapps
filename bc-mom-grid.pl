#!/bin/perl

# Uses fly to draw a transparent overly grid to help play Masters of
# Magic (in a window about 1000 pixels wide, or any consistent size--
# can be used for many other purposes too); overlay grid when using F2
# mode in Masters of Magic

require "/usr/local/lib/bclib.pl";

$gap = 75;
$gridcolor = "0,0,255";
$textcolor = "254,255,255";
$width = 1000;
$height = 675;

$str = "new\nsize $width,$height\nsetpixel 0,0,255,255,255\n";

for $i (0..$width/$gap) {
  $x = $i*$gap;
  $str .= "line 0,$x,1000,$x,$gridcolor\n";
  $str .= "line $x,0,$x,1000,$gridcolor\n";
  for $j (0..$height/$gap) {
    $y = $j*$gap;
    $xp = $x+2;
    $str .= "string $textcolor,$xp,$y,small,$x,$y\n";
  }
}

write_file($str,"/tmp/bcmomgrid.fly");
system("fly -q -i /tmp/bcmomgrid.fly -o /tmp/bcmomgrid.gif");
system("convert -transparent white /tmp/bcmomgrid.gif /tmp/bcmomgridfinal.gif");
system("xteddy -F/tmp/bcmomgridfinal.gif");


