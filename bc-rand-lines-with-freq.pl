#!/bin/perl

# A variant of 419/bc-rand-name.pl that takes a list of "name,freq"
# lines (where name may be repeated) and chooses a random line
# weighted by freq

# To use with
# https://www.ssa.gov/oact/babynames/state/namesbystate.zip remember
# to omit gender column

# Reference: https://www2.census.gov/topics/genealogy/2010surnames/names.zip

# Unofficial: http://ssdmf.info/download.html

require "/usr/local/lib/bclib.pl";

my(%freq, $total);

while (<>) {

  my($name, $freq) = csv($_);

  $freq{$name} += $freq;

  $total += $freq;
}

debug("TOT: $total");

debug(%freq);
