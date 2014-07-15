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
my($time) = `date +%s -d 'last Sunday'`;

# date range for db query (1 day on either side)

# and today (as stardate)
my($now) = strftime("%Y%m%d", localtime(time()));
# first day calendar will not show
my($lastday) = ($time+$globopts{weeks}*7+1)*86400;




# get relevant events
sqlite3hashlist("SELECT * FROM abqastro", "/home/barrycarter/BCGIT/db/abqastro.db");



die "TESTING";

# testing (pretend these happen everyday for now)
my(@events) = ("radicalness \@1300", "perpendicularity \@0900", "osmosis \@1700", "ball \@0100");

# calculated params
my($xwid) = $globopts{xsize}/7;
my($ywid) = $globopts{ysize}/$globopts{weeks};

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
    my($date) = ($week*7+$weekday+$time+.5)*86400;
    debug("DATE: $date");
    my($day) = strftime($dateformat, localtime($date));

    # sun/moon info (lat/lon = ABQ)
    # TODO: the -6*3600 below is a timezone hack (noon on day local)
    my(%smi) = sunmooninfo(-106.651138463684,35.0844869067959,$date-5*3600);

=item comment

THIS CODE IS NOT WORKING!

    for $i ("sun","moon") {
      # dawn/dusk don't exist for moon, but harmless
      for $j ("rise","set","dawn","dusk") {
	debug("ALPHA: $i/$j/$smi{$i}{$j}");
	my($astrodate) = strftime("%d", localtime($smi{$i}{$j}));
	if ($astrodate eq $day) {
	  $smi{$i}{$j} = strftime("%H%M", localtime($smi{$i}{$j}));
	} else {
	  $smi{$i}{$j} = "NA";
	}
	debug("$day: $i/$j/$smi{$i}{$j}");
      }
    }

=cut

    my($sr) = strftime("%H%M", localtime($smi{sun}{rise}));
    my($ss) = strftime("%H%M", localtime($smi{sun}{set}));
    my($cts) = strftime("%H%M", localtime($smi{sun}{dawn}));
    my($cte) = strftime("%H%M", localtime($smi{sun}{dusk}));

    # TODO: cleanup this code, its getting nasty
    # ignore moonrise/set on other days
    # TODO: not working, moonrise/set ignored for now
    my($mr,$ms);
    if (strftime("%d", localtime($smi{moon}{rise})) != $date) {
      $mr = "NA";
    } else {
      $mr = strftime("%H%M", localtime($smi{moon}{rise}));
    }

    if (strftime("%d", localtime($smi{moon}{set})) != $date) {
      $ms = "NA";
    } else {
      $ms = strftime("%H%M", localtime($smi{moon}{set}));
    }

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
