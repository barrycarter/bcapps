#!/bin/perl

# "completes" the Dink.ini file by creating SET_SPRITE_INFO lines for
# missing sprites per http://www.dinknetwork.com/forum.cgi?MID=192108

require "/usr/local/lib/bclib.pl";

for $i (split(/\n/,read_file("$bclib{githome}/DINK/dink-sequences.txt"))) {
  my($num,$file) = split(/\s+/, $i);
  $file=~s%^.*\\%%;
  $file=uc($file);
  my(@frames) = glob("$bclib{githome}/DINK/PNG/$file*");

  unless (@frames) {warn "$num/$file has no frames"; next;}
  debug("FRAMES($num/$file)",@frames);
}

