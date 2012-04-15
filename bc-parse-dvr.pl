#!/bin/perl

# I use i.tech's mdvr to record TV shows; however, the timer feature
# works poorly, so I just record 8-hour "batches" of shows, and this
# program parses them

# This is another program that's almost entirely for me, but I'm
# putting it into github JFF

push(@INC,"/usr/local/lib");
require "bclib.pl";

# file (fixed for now)
$file = "/var/tmp/mDVR001.3GP";

# length
($out, $err, $res) = cache_command("mplayer -identify $file -frames 0","age=60");

if ($out=~/ID_LENGTH=(.*?)\n/is) {$len=$1;} else {die "No length?";}

# the timestamp is the end time
($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$sizefile, $atime,$mtime,$ctime,$blksize,$blocks) = stat($file);

# so start time is
$stime = $mtime-$len;

debug($stime,$mtime);

# 11pm MDT = test time

$test = str2time("14 Apr 2012 23:00:00 MDT");

$startpos = $test-$stime;
$endpos = $startpos + 30*60;
warn "TESTING";
$endpos = $startpos + 60;

$cmd="mencoder -fps 29.97 $file -oac pcm -ovc copy -ss $startpos -endpos $endpos -o /var/tmp/test.mp4";

debug($cmd);

# system($cmd);

