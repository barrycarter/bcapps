#!/bin/perl

# Creates a Map.dat file where the nth screen is a copy of ts[n].bmp,
# as part of creating image-based screens

require "/usr/local/lib/bclib.pl";

# can do at most 512 tiles this way, not all 768

for $i (1..512) {
  # only the 21nd and 22nd byte are relevant
  print "\0"x20;

  my($s) = int(($i-1)/2);
  my($t) = ($i-1)%256;
  
