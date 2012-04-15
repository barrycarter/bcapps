#!/bin/perl

# I use i.tech's mdvr to record TV shows; however, the timer feature
# works poorly, so I just record 8-hour "batches" of shows, and this
# program parses them

# This is another program that's almost entirely for me, but I'm
# putting it into github JFF

push(@INC,"/usr/local/lib");
require "bclib.pl";


use Date::Manip;
# debug(ParseDateString("next Saturday after 14 Apr 2012"));

# debug(DateCalc(ParseDate("14 Apr 2012"), "next Saturday"));
# debug(Date_GetNext("14 Apr 2012", "Sat", 1, 19));
# debug(Date_GetNext("epoch 1234.56", "Sat", 1, 19));
# debug(Date_GetNext("epoch 1334449133", "Sat", 1, 19, 30));

# buffer, in seconds, around each "chunk"
$buffer = 180;

# file (fixed for now)
$file = "/var/tmp/mDVR001.3GP";

# length
($out, $err, $res) = cache_command("mplayer -identify $file -frames 0","age=60");

if ($out=~/ID_LENGTH=(.*?)\n/is) {$len=$1;} else {die "No length?";}

# the timestamp is the end time
($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$sizefile, $atime,$mtime,$ctime,$blksize,$blocks) = stat($file);

# so start time is... (using round to make Date::Manip happy)
$stime = round($mtime-$len);

# for each line in bc-parse-dvr.txt, determine if this chunk contains
# that timeframe
@lines = split(/\n/, read_file("/home/barrycarter/BCGIT/bc-parse-dvr.txt"));

for $i (@lines) {
  # ignore comments/blanks
  if ($i=~/^\#/ || $i=~/^\s*$/) {next;}

  debug(gsn_time($stime,$i));

  warn "TESTING";

  system("date");

  next;

  ($show, $day, $time, $len) = split(/\s+/, $i);
  $len||=30;

  # split time into hhmm for Date::Manip
  $time=~/^(\d{2})(\d{2})$/||die "BAD TIME: $time";
  ($hour, $min) = ($1, $2);

  # if hour is between 0 and 5, it's really the next day
  # TODO: more here
  if ($hour<=5) {}


  # next time this show starts
  debug("SENDING: $stime, $day, $hour, $min");
  $next = Date_GetNext("epoch $stime", $day, 1, $hour, $min);
  $next = UnixDate($next, "%s");
  debug("GETTING: $next");

#  debug("$show, $day, $time, $len, $next");
}

die "TESTING";

# and length is (presumably read from file)
$length = 30*60 + 2*$buffer;

# 11pm MDT = test time

$test = str2time("14 Apr 2012 23:00:00 MDT");
$startpos = $test-$stime;

# this is an ugly way to convert seconds to HMS and only accurate to 24h
$ss = strftime("%H:%M:%S", gmtime($startpos-$buffer));

$cmd="mencoder -fps 29.97 $file -oac pcm -ovc copy -ss $ss -endpos $length -o /var/tmp/test.mp4";

debug($cmd);
system($cmd);

=item gsn_time($stime, $descrip)

Find the first occurring described time ($descrip) after $stime (in
Unix seconds), using "GSN time", which is ET, plus says "tue 0200"
when they mean "wed 0200" (times before 6am are listed as previous
day)

=cut

sub gsn_time {
  my($stime, $descrip) = @_;
  my(%nday);

  # I'm surprised this works, but it does
  local($ENV{TZ}) = "America/New_York";

  # clever (but very inefficient) way to find next day (and I\'m
  # putting it in a subroutine too, sigh!)

  for $i (0..6) {
    my($day) = strftime("%a", gmtime($i*86400+43200));
    my($nday) = strftime("%a", gmtime(($i+1)*86400+43200));
    $nday{$day} = $nday;
  }

  # TODO: handle "Wek"

  # break into pieces (don\'t need $len (or $show for that matter))
  my($x, $day, $time) = split(/\s+/, $descrip);

  # split hour/min
  $time=~/^(\d{2})(\d{2})$/||warn("BAD TIME: $time");
  my($hour,$min) = ($1,$2);

  # if before or at 5am, fix day
  if ($hour <= 5) {$day = $nday{$day};}

  # Date::Manip does the work
  debug("$stime, $day, 1, $hour, $min");
  my($res) = UnixDate(Date_GetNext("epoch $stime", $day, 1, $hour, $min),"%s");

  debug("$descrip -> $res");

  return $res;

}


