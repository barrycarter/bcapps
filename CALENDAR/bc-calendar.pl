#!/bin/perl

# creates a graphic calendar I can put on the background of X11
# Options:
# xsize/ysize - size of calendar (default 800x600) [really 801x601]
# weeks - number of weeks to show (default 5)
# font1 - size for all "fixed" text on calendar excl date
# eventsize - size for events

require "/usr/local/lib/bclib.pl";

defaults("xsize=800&ysize=600&weeks=7&font1=tiny&eventsize=small&datesize=giant&monthsize=medium&moonstampfont=medium&moonstampcolor=255,0,0");

# font heights and widths for fly
# TODO: put in bclib.pl?

%fht = ("tiny" => 8, "small" => 12, "medium" => 13, "large" => 16, "giant" => 15);

%fwd = ("tiny" => 5, "small" => 6, "medium" => 7, "large" => 8, "giant" => 9);

# read events file
for $i (`grep -hv '^#' /home/barrycarter/calendar.d/*.txt`) {

  # ignore blanks
  if ($i=~/^\s*$/) {next;}

  if ($i=~/^(\d{8})\s+(.*)$/) {
    my($date, $event) = ($1, $2);
    # format yyyymmdd
    push(@{$events{$date}}, $event);
  } elsif ($i=~/^(MON|TUE|WED|THU|FRI|SAT|SUN)\s+(.*)$/) {
    # format every week
    push(@{$events{$1}}, $2);
  } elsif ($i=~/^\-(\d{8})\s+(.*)$/) {
    # ugly way to do exclusions
    $exclude{$1}{$2} = 1;
  } else {
    warn "NOT UNDERSTOOD: $i";
  }
}

# last sunday (in seconds) + one week extra
# GMT for JD later
my($time) = `date +%s -d '1200 last Sunday GMT'`-86400*7;
# and today (as stardate)
my($now) = strftime("%Y%m%d", localtime(time()));

# date range for db query (1 day on either side)
my($sdate) = strftime("%Y-%m-%d", localtime($time-86400*8));
my($edate) = strftime("%Y-%m-%d", localtime($time+$globopts{weeks}*7*86400));

# get relevant events and hash to date
for $i (sqlite3hashlist("SELECT * FROM abqastro WHERE time>='$sdate' AND time<='$edate'", "/home/barrycarter/BCGIT/db/abqastro.db")) {
  # this is easier (but slower?) than using substr (seconds optional)
  $i->{time}=~/^(....)\-(..)\-(..) (..):(..)/||die("BAD TIME: $i->{time}");
  my($stardate, $etime) = ("$1$2$3", "$4$5");
  $hash{$stardate}{$i->{event}} = $etime;

  # moon major phase
  if ($i->{event}=~/moon|quarter/i) {
    # record time of new moon for lunar age calcs (if two new, latest)
    if ($i->{event} eq "New Moon") {$newmoon = str2time($i->{time});}
    # just cap letters
    $i->{event}=~s/[a-z\s]//g;
    $hash{$stardate}{moonstamp} = $etime;
  }
}

# calculated params
my($xwid) = $globopts{xsize}/7;
my($ywid) = $globopts{ysize}/$globopts{weeks};

# choice params below (maybe later)

# date position (relative) + color/size
my($xpos) = .8;
my($ypos) = .05;
my($datecolor) = "255,255,0";
my($dateformat) = "%d";

# grid color
my($gridcolor) = "0,0,255";

# TODO: make these all params
# event spacing/etc
my($eventspacing) = 15;
my($eventcolor) = "255,128,128";
# below replaced with $yprint
# my($eventystart) = 35;

# putting image on background uses up too much colormap, -colors 128 fixes
open(A,"|tee /tmp/calfly.txt|fly -q|convert - -colors 128 /tmp/cal0.gif");
# 1 more pixel to get right and bottom grid lines
print A "new\nsize ",$globopts{xsize}+1,",",$globopts{ysize}+1,"\nsetpixel 0,0,0,0,0\n";

for $week (-1..$globopts{weeks}-1) {
  for $weekday (0..6) {

    # current day (in unix, print, month only, and stardate formats)
    my($date) = ($week*7+$weekday)*86400+$time;
    my($month) = strftime("%b", localtime($date));
    my($day) = strftime($dateformat, localtime($date));
    my($stardate) = strftime("%Y%m%d", localtime($date));
    my($jd) = jd2unix($date, "unix2jd");

    # sidereal time at noon
    # TODO: this assumes MT = GMT-6 or -7 which isn't always true
    # TODO: don't hardcode ABQ longitude
    my($sd) = fmodp(gmst($date+7*3600)-106.651138463684/15.,24);
    $sd = sprintf("%02dh%02dm",int($sd), round($sd*60%60));

    # moon age (this is not 100% accurate)
    # odd rounding since only even numbered gifs exist
    my($moonage) = sprintf("%0.3d", round(180*fmodp(($date-$newmoon)/2551442.889600,1))*2);
    debug("MA: $moonage");

    # x and y for top left
    my($x1, $y1) = ($globopts{xsize}*$weekday/7, $globopts{ysize}*$week/$globopts{weeks});
    # and bottom right
    my($x2, $y2) = ($x1+$xwid, $y1+$ywid);
    # bottom left of where day is printed
    my($dx, $dy) = ($x1+$xpos*$xwid, $y1+$ypos*$ywid);

    # testing putting date as far right as possible
    # 2.5 gives it a half character spacing from the blue grid line
    $dx = $x1+$xwid-2.5*$fwd{$globopts{datesize}};

    # sidereal time
    print A join(",", "string",64,64,64,$x1+4,$y1+$ywid-9,$globopts{font1},$sd),"\n";
    # JD bottom right (do I really want this?)
    print A join(",", "string",64,64,64,$x1+$xwid-35,$y1+$ywid-9,$globopts{font1},$jd), "\n";
    # Unix date (seconds/86400 for most of day)
    print A join(",", "string",64,64,64,$x1+$xwid-70,$y1+$ywid-9,$globopts{font1}, sprintf("%d", $date/86400)), "\n";
#    debug("DATE",sprintf("%d", $date/86400));

    # must come before red box to avoid overlap
#    print A "copy ",join(",", $x1+70, $y1+15, 0, 0, 21, 21, "/home/barrycarter/20140716/m$moonage.gif.temp"),"\n";

    # better positioning based on params
     print A "copy ",join(",", $x1+$xwid-4*$fwd{$globopts{datesize}}, $y1+15+$fht{$globopts{datesize}}, 0, 0, 21, 21, "/home/barrycarter/20140716/m$moonage.gif.temp"),"\n";

    # resize attempt to preserve ratio
#    print A "copy ",join(",", $x1+$xwid-4*$fwd{$globopts{datesize}}, $y1+15+$fht{$globopts{datesize}}, 0, 0, 21/800*$globopts{xsize}, 21/600*$globopts{ysize}, "/home/barrycarter/20140716/m$moonage.gif.temp"),"\n";

    my($moonstr)="SR: $hash{$stardate}{MS}-$hash{$stardate}{MR}";
    if ($hash{$stardate}{MR} < $hash{$stardate}{MS}) {
      $moonstr="RS: $hash{$stardate}{MR}-$hash{$stardate}{MS}";
    }

    # printing stamp first helps? (no, much worse)
    if ($hash{$stardate}{moonstamp}) {
#      print A "string ",join(",", $datecolor, $x1+71, $y1+20, $globopts{font1}, $hash{$stardate}{moonstamp}),"\n";
      print A "string ",join(",", $globopts{moonstampcolor}, $x1+$xwid-4*$fwd{$globopts{datesize}}+1, $y1+20+$fht{$globopts{datesize}}, $globopts{moonstampfont}, $hash{$stardate}{moonstamp}),"\n";
    }

    # print stuff
    my($yprint) = $dy;
    # put month to left of date
#    print A "string $datecolor,",$dx-20,",$yprint,$globopts{font1},$month\n";
    print A "string $datecolor,",$dx-2.5*$fwd{$globopts{datesize}}-0*$fwd{$globopts{monthsize}},",$yprint,$globopts{monthsize},$month\n";
    print A "string $datecolor,",$x1+5,",$yprint,$globopts{font1},$hash{$stardate}{SR}-$hash{$stardate}{SS}\n";

    $yprint += $fht{$globopts{font1}};

    print A "string $datecolor,",$x1+5,",",$yprint,",$globopts{font1},$hash{$stardate}{CTS}-$hash{$stardate}{CTE}\n";

    $yprint += $fht{$globopts{font1}};

    print A "string 255,255,255,",$x1+5,",",$yprint,",$globopts{font1},$moonstr\n";

    $yprint += $fht{$globopts{font1}};

    # highlight date if today
    if ($stardate == $now) {
      print A "frect,",$dx-1,",",$y1+5,",",$x2-5,",",$dy+15,",255,0,0\n";
      print A "string 255,255,255,$dx,$dy,$globopts{datesize},$day\n";
    } else {
      print A "string $datecolor,$dx,$dy,$globopts{datesize},$day\n";
    }

    # events for this day
    my(@events) = @{$events{$stardate}};
    # events for this day (of the week)
    push(@events, @{$events{uc(strftime("%a", localtime($date)))}});
    # events in year 0000 mean "every year"
    my($zerodate) = $stardate;
    $zerodate=~s/^..../0000/;
    push(@events, @{$events{$zerodate}});
    debug("EVENTS($stardate):",@events);

    # to deal with excludes, we need a separate counter
    my($count)=-1;

    for $i (0..$#events) {
      if ($exclude{$stardate}{$events[$i]}) {next;}

      $count++;

      if ($count > 3) {warn "More than 3 events for $stardate!";}

      my($eventy) = $y1+$eventystart+$eventspacing*$count;
      my($eventy) = $yprint+$eventspacing*$count;
      my($eventx) = $x1+5;
      # different color for "?" events
      if ($events[$i]=~s/^\?//) {
	print A "string 64,64,64,$eventx,$eventy,$globopts{eventsize},$events[$i]\n";
      } else {
	print A "string $eventcolor,$eventx,$eventy,$globopts{eventsize},$events[$i]\n";
      }
    }

#    print A "settile /home/barrycarter/BCGIT/images/MOON/m288.gif\n";

#    if (rand() < .1) {
#    print A "setstyle 255,0,0,255,255,0,255,255,255\n";
#  } else {
#    print A "killstyle\n";
#  }

    if (rand() < 0) {
#      print A "filltoborder ",$x1+1,$y1+1,"0,0,255,0,0,255\n";
      print A "setbrush /tmp/test.gif\n";
    }

    # grid lines
    if (rand() < 0) {
      print A "frect $x1,$y1,$x2,$y2,$gridcolor\n";
    } else {
      print A "rect $x1,$y1,$x2,$y2,$gridcolor\n";
    }

#    print A "killbrush\n";
#    $gridcolor = "0,0,255";

  }
}

close(A);

# transparentify for overlay
system("convert -transparent black /tmp/cal0.gif /usr/local/etc/calendar.gif");

