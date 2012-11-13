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
  # TODO: better use of tempfile (but do need one, process takes a while)
  # TODO: in theory, could create SRT while we read, but bad?
  system("mplayer -subcc 1 -speed 100 -nosound -vo null dvd://$i &> /tmp/out2.txt");

  die "TESTING";
}


