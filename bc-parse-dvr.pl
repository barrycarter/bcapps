#!/bin/perl

# I use i.tech's mdvr to record TV shows; however, the timer feature
# works poorly, so I just record 8-hour "batches" of shows, and this
# program parses them

# This is another program that's almost entirely for me, but I'm
# putting it into github JFF

push(@INC,"/usr/local/lib");
require "bclib.pl";


use Date::Manip;

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

# I hate my system, so let's do this in parallel
open(A,"|parallel -j 20");

for $i (@lines) {
  # ignore comments/blanks
  if ($i=~/^\#/ || $i=~/^\s*$/) {next;}

  # split (just for $show/$len, only gsn_time uses $day/$time)
  ($show, $day, $time, $len) = split(/\s+/, $i);
  $len||=30;

  # unix time that this occurs next
  $sshow = gsn_time($stime,$i);
  debug(gsn_time($stime,$i));

  unless ($stime < $sshow && $sshow < $mtime) {
#    debug("$i not in this recording");
    next;
  }

  # recording is in this file, but is it clipped?
  if ($sshow + $len*60 > $mtime) {
    # TODO: more with this
    print "CLIPPED\n";
  }

#  print "$i IS in this recording\n";

  # find start time in HMS format (ugly!)
  # TODO: buffering!
  $ss = strftime("%H:%M:%S", gmtime($sshow-$stime-$buffer));
  # length of show, in seconds
  $length = $len*60+2*$buffer;

  # name of outfile
  $oname = strftime("/var/tmp/$show-%Y%m%d%H%M.mp4", localtime($sshow));

  debug("ONAME: $oname");

  # command to extract
  $cmd="mencoder -quiet -fps 29.97 $file -oac pcm -ovc copy -ss $ss -endpos $length -o $oname";
  print A "$cmd\n";
}

close(A);

=item gsn_time($stime, $descrip)

Find the first occurring described time ($descrip) after $stime (in
Unix seconds), using "GSN time", which is ET, plus says "tue 0200"
when they mean "wed 0200" (times before 6am are listed as previous
day)

=cut

sub gsn_time {
  my($stime, $descrip) = @_;
  my(%nday);
  my(@temp);

  # I'm surprised this works, but it does
  local($ENV{TZ}) = "America/New_York";

  # clever (but very inefficient) way to find next day (and I\'m
  # putting it in a subroutine too, sigh!)

  for $i (0..6) {
    my($day) = lc(strftime("%a", gmtime($i*86400+43200)));
    my($nday) = lc(strftime("%a", gmtime(($i+1)*86400+43200)));
    $nday{$day} = $nday;
  }

  # break into pieces (don\'t need $len (or $show for that matter))
  my($x, $dow, $time) = split(/\s+/, $descrip);

  # if "m-f", find lowest time that exceeds $stime
  if ($dow=~/^m\-f$/) {
    for $i (split(/\,/,"mon,tue,wed,thu,fri")) {
      debug("SENDING: $x $i $time");
      my($gtime) = gsn_time($stime, "$x $i $time");
      # if before $stime, ignore it
      if ($gtime < $stime) {next;}
      push(@temp, $gtime);
    }

    # and return the smallest such
    return min(@temp);
  }

  # split hour/min
  $time=~/^(\d{2})(\d{2})$/||warn("BAD TIME: $time");
  my($hour,$min) = ($1,$2);

  # if before or at 5am, fix dow
  if ($hour <= 5) {$dow = $nday{$dow};}

  # Date::Manip does the work
#  debug("CALLING: $stime, $dow, 1, $hour, $min");
  my($res) = UnixDate(Date_GetNext("epoch $stime", $dow, 1, $hour, $min),"%s");

  # Date::Manip can give results in past, fix
  if ($res < $stime) {$res+=7*86400;}

#  debug("$descrip -> $res");

  return $res;

}


