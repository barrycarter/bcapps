#!/bin/perl

# creates a graphic calendar I can put on the background of X11

require "/usr/local/lib/bclib.pl";

# params
my($xsize, $ysize) = (800,600);
my($weeks) = 5;

open(A,"|fly -o /tmp/cal0.gif");
print A "new\nsize $xsize,$ysize\nsetpixel 0,0,0,0,0\n";

for $weekday (0..6) {
  for $week (0..$weeks-1) {
    # x and y for top left
    my($x1, $y1) = ($xsize*$weekday/7, $ysize*$week/$weeks);
    # and bottom right
    my($x2, $y2) = ($x1+$xsize/7, $y1+$ysize/$weeks);
    # bottom left of day
    my($dx, $dy) = ($x1+.9*$xsize/7, $y1+.1*$ysize/$weeks);
    print A "rect $x1,$y1,$x2,$y2,255,255,255\n";
    $day++;
    print A "string 255,255,255,$dx,$dy,giant,$day\n";
    debug("WEEK: $i, DAY: $j");
  }
}

close(A);
