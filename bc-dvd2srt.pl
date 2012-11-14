#!/bin/perl

# attempts to use closed captioning (not subtitles) to create an srt
# file for a DVD.
#
# REQUIRES MY EDITED VERSION OF MPLAYER (see .c files in this directory)

require "/usr/local/lib/bclib.pl";

# determine number of titles
$tits = `mplayer dvd://1 -frames 0 -vo null -ao null`;
unless ($tits=~/there are (\d+) titles on this dvd./is) {
  die "Can't determine number of titles";
}
$tits = $1;

# go through each title and count chapters
for $i (1..$tits) {
  # extract cc as fast as possible
  # TODO: printing file while reading is inefficient
  open(A,"mplayer -subcc 1 -speed 100 -nosound -vo null dvd://$i 2>&1|");

  while(<A>) {
    chomp;

    # if this line is a timestamp, record it and move on
    if (/v:\s+(.*?)\s+/i) {
      $time = $1;
      next;
    }

    # if time hasnt been set at all yet, ignore lines
    unless ($time) {next;}

    # find milliseconds as 3 digits (strftime doesnt do this?)
    $milli = sprintf("%0.3d",($time-int($time))*1000);

    # convert time to SRT format
    $str = strftime("%H:%M:%S",gmtime($time));
    debug("STR: $str,$milli");

    # this probably wont work, early test only
    $count++;
    $time=~s/\./,/isg;
    print << "MARK";
$count
$str,$milli --> $str,$milli
$_

MARK
;
}

die "TESTING";

}



