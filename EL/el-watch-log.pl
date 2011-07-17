#!/bin/perl

# Watches the EL log files and plays a "cheerful melody" when I stop
# harvesting (may add more to this later)

# NOTE: I realize this is a trivial program

require "bclib.pl";

# locating melody in git so everyone can have it
$sound = "$ENV{HOME}/BCGIT/EL/cheerful.mp3";

open(A, "tail -1f $ENV{HOME}/.elc/main/srv_log.txt|");

# Right now, alerts to ANY change in chat_log.txt (so could've just
# used iwatch, but I plan to limit when the sound plays)

while (<A>) {
  unless (/harvest/i && /stop/i) {next;}
  # Even in "really-quiet" mode, mplayer spews out errors, so devnulling
  system("mplayer -really-quiet $sound 1> /dev/null 2> /dev/null &");
}

