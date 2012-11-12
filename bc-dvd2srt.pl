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
  $chaps = `mplayer dvd://$i -frames 0 -vo null -ao null`;
  debug("CHAPS: $chaps");
  unless ($chaps=~/there are (\d+) chapters in this dvd title\./is) {
    warn("Can't determine number of chapters for title $i");
    next;
  }
  $chaps = $1;

  debug("TITLE: $i, CHAP: $chaps");
}
