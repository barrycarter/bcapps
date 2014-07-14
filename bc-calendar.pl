#!/bin/perl

# creates a graphic calendar I can put on the background of X11

require "/usr/local/lib/bclib.pl";

# test file w/ some events
require "/home/barrycarter/20140713/test.pl";

# testing (pretend these happen everyday for now)
my(@events) = ("radicalness \@1300", "perpendicularity \@0900", "osmosis \@1700", "ball \@0100");


# params
my($xsize, $ysize) = (800,600);
my($weeks) = 5;

# calculated params
my($xwid) = $xsize/7;
my($ywid) = $ysize/$weeks;

# choice params below

# date position (relative) + color/size
my($xpos) = .8;
my($ypos) = .05;
my($datecolor) = "255,255,0";
my($datesize) = "giant";
my($dateformat) = "%d";

# grid color
my($gridcolor) = "0,0,255";

# TODO: make these all params
# event spacing/etc
my($eventspacing) = 15;
my($eventsize) = "small";
my($eventcolor) = "255,128,128";
my($eventystart) = 20;

# last sunday (in days)
my($time) = int(`date +%s -d 'last Sunday'`/86400);

open(A,"|fly -o /tmp/cal0.gif");
print A "new\nsize $xsize,$ysize\nsetpixel 0,0,0,0,0\n";

for $week (0..$weeks-1) {
  for $weekday (0..6) {
    # current day
    $date = ($week*7+$weekday+$time+.5)*86400;
    $day = strftime($dateformat, localtime($date));
    # x and y for top left
    my($x1, $y1) = ($xsize*$weekday/7, $ysize*$week/$weeks);
    # and bottom right
    my($x2, $y2) = ($x1+$xwid, $y1+$ywid);
    # bottom left of day
    my($dx, $dy) = ($x1+$xpos*$xwid, $y1+$ypos*$ywid);

    # events for this day
    my(@events) = @{$events{$week*7+$weekday+$time}};
    for $i (0..$#events) {
      my($eventy) = $y1+$eventystart+$eventspacing*$i;
      my($eventx) = $x1+5;
      print A "string $eventcolor,$eventx,$eventy,$eventsize,$events[$i]\n";
    }

    print A "rect $x1,$y1,$x2,$y2,$gridcolor\n";
    print A "string $datecolor,$dx,$dy,$datesize,$day\n";
    debug("WEEK: $i, DAY: $j");
  }
}

close(A);
