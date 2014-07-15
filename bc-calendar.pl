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
my($eventystart) = 25;

# last sunday (in days)
my($time) = int(`date +%s -d 'last Sunday'`/86400);
# and today (as stardate)
my($now) = strftime("%Y%m%d", localtime(time()));

open(A,"|fly -o /tmp/cal0.gif");
# 1 more pixel to get right and bottom grid lines
print A "new\nsize ",$xsize+1,",",$ysize+1,"\nsetpixel 0,0,0,0,0\n";

for $week (0..$weeks-1) {
  for $weekday (0..6) {

    # x and y for top left
    my($x1, $y1) = ($xsize*$weekday/7, $ysize*$week/$weeks);
    # and bottom right
    my($x2, $y2) = ($x1+$xwid, $y1+$ywid);
    # bottom left of day
    my($dx, $dy) = ($x1+$xpos*$xwid, $y1+$ypos*$ywid);

    # current day
    my($date) = ($week*7+$weekday+$time+.5)*86400;
    my($day) = strftime($dateformat, localtime($date));

    # and month if new month or diagonal
    # compromise between putting month on every day + not often enough
    # TODO: maybe also on last day of month? (sideways?)
    if ($day eq "01" || ($weekday==$week)) {
      # month abrrev
      my($month) = strftime("%b", localtime($date));
      # TODO: don't hardcode number
      print A "string 255,0,255,",$dx-30,",$dy,$datesize,$month\n";
    }

    # in "stardate" format (which is how I store entries)
    my($stardate) = strftime("%Y%m%d", localtime($date));

    # events for this day
    my(@events) = @{$events{$stardate}};
    for $i (0..$#events) {
      my($eventy) = $y1+$eventystart+$eventspacing*$i;
      my($eventx) = $x1+5;
      print A "string $eventcolor,$eventx,$eventy,$eventsize,$events[$i]\n";
    }

    print A "rect $x1,$y1,$x2,$y2,$gridcolor\n";

    if ($stardate == $now) {
      print A "frect,",$dx-3,",",$y1+2,",",$x2-3,",",$dy+20,",255,0,0\n";
      print A "string 255,255,255,$dx,$dy,$datesize,$day\n";
    } else {
      print A "string $datecolor,$dx,$dy,$datesize,$day\n";
    }
  }
}

close(A);
