#!/bin/perl

# Uses mplayer to help me subtitle audio; subtitleencoder lacks many
# features I want plus has an icky GUI

require "/usr/local/lib/bclib.pl";

# not really using this to do lyrics, but good test?
$file = "/mnt/sshfs/MP3/howdoyoutalktoanangel.mp3";

# TODO: better naming convention
open(A,">>/var/tmp/$file.srt")||die("Can't open file");

# TODO: this should be file length, not fixed value
for ($i=0; $i<=500; $i+=2) {
  # buffer of 0.1 seconds (which may result in redundancies)
  $start = $i-0.1;
  system("mplayer -really-quiet -ss $start -endpos 2.2 $file");
  $get = <STDIN>;
  chomp($get)

  # commands start with !

  # TODO: allow for commands
  print A "$i $get\n";
}


