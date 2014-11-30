#!/bin/perl

# Trivial script that lines up header.430_572 constant names to values

require "/usr/local/lib/bclib.pl";

$all = read_file("$bclib{githome}/ASTRO/header.430_572");

debug("ALL: $all");

# cheating slightly here

$all=~s/(DENUM.*?)GROUP/GROUP/s;
my($names) = $1;
my(@names) = split(/\s+/, $names);

debug("ALL: $all");

# the values
$all=~s/1041.*?(0\..*?)GROUP//s;
my($vals) = $1;
my(@vals) = split(/\s+/, $vals);

for $i (0..$#names) {
  print "$names[$i]: $vals[$i]\n";
}


