#!/bin/perl

# some of my older glut stuff (not here) doesnt have "glutInit" since
# older versions of glut didnt require it; this fixes those scripts

require "/usr/local/lib/bclib.pl";

# these are all kept in this dir
chdir("/home/barrycarter/20130415");

# numbered 1 to 168
for $i (1..168) {
  $all = read_file("$i.c");

  # already has glutinit? do nothing
  if ($all=~/glutinit\(/is) {next;}

  unless ($all=~s/(glutInitDisplayMode)/glutInit(\&argc, argv)\; $1/is) {
    warn "Can't find place to stick it: glutinit";
    next;
  }

  # write new file and compile it
  write_file($all,"new$i.c");
  system("gcc -lglut new$i.c -o run$i");

#  debug("I: $i");
}

