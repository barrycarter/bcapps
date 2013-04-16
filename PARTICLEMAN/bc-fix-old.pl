#!/bin/perl

# some of my older glut stuff (not here) doesnt have "glutInit" since
# older versions of glut didnt require it; this fixes those scripts

require "/usr/local/lib/bclib.pl";

# these are all kept in this dir
chdir("/home/barrycarter/20130415");

# numbered 1 to 168
for $i (1..168) {
  # compiled ones have a 'run' file
  if (-f "run$i") {next;}
  debug("I: $i");
}

