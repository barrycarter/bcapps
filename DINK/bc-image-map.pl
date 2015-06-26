#!/bin/perl

# Creates a Map.dat file where the nth screen is a copy of ts[n].bmp,
# as part of creating image-based screens

require "/usr/local/lib/bclib.pl";

# create dink.dat (always 11488 bytes)

open(A,">temp.dink.dat");

# 20 characters garbage
print A "Smallwood";
print A "\0"x12;

# screen indices as 4 byte integers
for $i (1..511) {
# for $i (1..5) {
  print A "\x0\x0";
  if ($i<=255) {print A "\x0",chr($i); next;}
  print A "\x1",chr($i-256);
}

# rest of the file can be empty (ie, null)
print A "\0"x9424;

close(A);

# can do at most 512 tiles this way, not all 768

for $i (1..256) {

  # each value of $ts references two tile screens
  my($ts) = int(($i-1)/2);

  # and each of the tiles in screen 1
  for $j (0..95) {print "\0"x20,chr($ts),chr($j),"\0"x58;}
  # empty data for rest of screen 1
  print "\0"x23600;
  # tiles in screen 2
  for $j (128..128+95) {print "\0"x20,chr($ts),chr($j),"\0"x58;}
  # empty data for rest of screen 2
  print "\0"x23600;
}
