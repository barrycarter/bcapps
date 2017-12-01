#!/bin/perl

# this is a oneoff program

# parses the output of
# sudo rdfind -dryrun true -removeidentinode false -makesymlinks true dir1 dir2
# (on the STDIN) that recommends symlinks, but with oneoff exceptions I need

require "/usr/local/lib/bclib.pl";

while (<>) {

  # make sure its a symlink recommendation
  unless (/symlink\s*(.*?)\s+to\s+(.*)$/) {next;}

  debug("GOT: $1 -> $2");

  
}
