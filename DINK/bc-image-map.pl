#!/bin/perl

# Creates a Map.dat file where the nth screen is a copy of ts[n].bmp,
# as part of creating image-based screens

require "/usr/local/lib/bclib.pl";

# create dink.dat (always 11488 bytes)
my($str)="Smallwood"."\0"x13;

# screen indices as 4 byte integers
# for $i (1..511) {
for $i (0..511) {
  $str.="\x0\x0";
  if ($i<=255) {$str.=chr($i)."\x0"; next;}
  $str.=chr($i-256)."\x1";
}

# rest of the file can be empty (ie, null)
$str.="\0"x(11488-length($str));

write_file($str,"temp.dink.dat");

# can do at most 512 tiles this way, not all 768

# for $i (1..256) {
for $i (1..150) {

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
