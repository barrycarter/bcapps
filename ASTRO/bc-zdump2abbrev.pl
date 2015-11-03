#!/bin/perl

# For each time zone in the output of:
# find /usr/share/zoneinfo -type f | xargs -n 1 zdump -v
# find the latest (and thus most likely current) abbreviation

# Note that abbreviations are not unique (tzdata uses EDT for both the
# United States and Australia's eastern daylight timezones), but this
# should help me canonize time zone names (maybe)

require "/usr/local/lib/bclib.pl";

open(A,"bzcat $bclib{githome}/ASTRO/zdump.txt.srt.bz2|");

while (<A>) {
  debug("GOT: $_");
}


