#!/bin/perl

# creates a graphic calendar I can put on the background of X11
# Options:
# xsize/ysize - size of calendar (default 800x600) [really 801x601]
# weeks - number of weeks to show (default 5)

require "/usr/local/lib/bclib.pl";


# test file w/ some events
require "/home/barrycarter/20140713/test.pl";

defaults("xsize=800&ysize=600&weeks=5");

# last sunday (in seconds)
my($time) = `date +%s -d '1200 last Sunday'`;
# and today (as stardate)
my($now) = strftime("%Y%m%d", localtime(time()));

# date range for db query (1 day on either side)
my($sdate) = strftime("%Y-%m-%d", localtime($time-86400));
my($edate) = strftime("%Y-%m-%d", localtime($time+$globopts{weeks}*7*86400));

# get relevant events and hash to date
for $i (sqlite3hashlist("SELECT * FROM abqastro WHERE time>='$sdate' AND time<='$edate'", "/home/barrycarter/BCGIT/db/abqastro.db")) {
  $hash{substr($i->{time}, 0, 10)}{$i->{event}} = substr($i->{time}, 11, 5);
}

# calculated params
my($xwid) = $globopts{xsize}/7;
my($ywid) = $globopts{ysize}/$globopts{weeks};

# choice params below (maybe later)

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

open(A,"|fly -o /tmp/cal0.gif");
# 1 more pixel to get right and bottom grid lines
print A "new\nsize ",$globopts{xsize}+1,",",$globopts{ysize}+1,"\nsetpixel 0,0,0,0,0\n";

for $week (0..$globopts{weeks}-1) {
  for $weekday (0..6) {

    # x and y for top left
    my($x1, $y1) = ($globopts{xsize}*$weekday/7, $globopts{ysize}*$week/$globopts{weeks});
    # and bottom right
    my($x2, $y2) = ($x1+$xwid, $y1+$ywid);
    # bottom left of where day is printed
    my($dx, $dy) = ($x1+$xpos*$xwid, $y1+$ypos*$ywid);

    # current day
    my($date) = ($week*7+$weekday)*86400+$time;
    debug("DATE: $date");
    my($day) = strftime($dateformat, localtime($date));


    my($moonstr);
#    if ($mr<$ms) {$moonstr="RS: $mr/$ms";} else {$moonstr="SR: $ms/$mr"};

    # and month if new month or diagonal
    # compromise between putting month on every day + not often enough
    # TODO: maybe also on last day of month? (sideways?)
#    if ($day eq "01" || ($weekday==$week)) {
      # month abrrev
      my($month) = strftime("%b", localtime($date));
      # TODO: don't hardcode number
      print A "string $datecolor,",$dx-20,",$dy,tiny,$month\n";
#    }

    # sun/civil
    # TODO: this is inaccurate, off by up to a day
    print A "string $datecolor,",$x1+5,",$dy,tiny,$sr-$ss\n";
    print A "string $datecolor,",$x1+5,",",$dy+10,",tiny,$cts-$cte\n";
    print A "string 255,255,255,",$x1+5,",",$dy+20,",tiny,$moonstr\n";

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
