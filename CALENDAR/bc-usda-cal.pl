#!/bin/perl

# Converts
# http://snap.nal.usda.gov/nutrition-through-seasons/holiday-observances
# (local copy in this directory) to iCalendar format

require "/usr/local/lib/bclib.pl";

my($all) = read_file("$bclib{githome}/CALENDAR/holiday-observances.html");

# fixed dates
while ($all=~s%<li>(.*?)\s*\((.*?)\).%%) {
  debug("GOT: $1 -> $2");
}

