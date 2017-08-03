#!/bin/perl

# When you play WWF w/ someone, it stores each word you play as:
# <X> just played <Y> for <Z> points

# this attempts to parse that log, since bc-parse-wwf.pl no longer works

require "/usr/local/lib/bclib.pl";

my($all,$name) = cmdfile();

while ($all=~s/data-utime="([\d\.]+)//) {
  debug("GOT: $1");
}


# TODO: add "swapped tiles" and maybe "pokes"
while ($all=~s/>([^>]*?) just played (.*?) for (.*?) points//) {

debug("GOT: $1 $2 $3");

}




