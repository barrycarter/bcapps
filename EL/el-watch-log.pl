#!/bin/perl

# Watches the EL log files and plays a "cheerful melody" when I stop
# harvesting (may add more to this later)

# NOTE: I realize this is a trivial program

require "bclib.pl";

# locating melody in git so everyone can have it
$sound = "$ENV{HOME}/BCGIT/EL/cheerful.mp3";

open(A, "tail -1f $ENV{HOME}/.elc/main/chat_log.txt|");

# Right now, alerts to ANY change in chat_log.txt (so could've just
# used iwatch, but I plan to limit when the sound plays)

while (<A>) {
  system("mplayer -really-quiet $sound &");
}

