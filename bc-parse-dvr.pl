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

debug(Date_GetNext("epoch 1234", "Sat", 1, 19));




die "TESTING";

# buffer, in seconds, around each "chunk"
$buffer = 180;

debug(strftime("%H:%M:%S", gmtime(100)));

# file (fixed for now)
$file = "/var/tmp/mDVR001.3GP";

# length
($out, $err, $res) = cache_command("mplayer -identify $file -frames 0","age=60");

if ($out=~/ID_LENGTH=(.*?)\n/is) {$len=$1;} else {die "No length?";}

# the timestamp is the end time
($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$sizefile, $atime,$mtime,$ctime,$blksize,$blocks) = stat($file);

# so start time is...
$stime = $mtime-$len;

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

