#!/bin/perl

# Creates a Map.dat file where the nth screen is a copy of ts[n].bmp,
# as part of creating image-based screens

require "/usr/local/lib/bclib.pl";

# can do at most 512 tiles this way, not all 768

for $i (1..512) {
  # for each screen, the first tile screen
  my($ts) = int(($i-1)/2);
  # and each of the tiles for first/second screen
  for $j (0..95,128..128+95) {print "\0"x20,chr($ts),chr($j),"\0"x58;}
}
