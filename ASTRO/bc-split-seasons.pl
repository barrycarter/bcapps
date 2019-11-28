#!/bin/perl

# given a list of per-minute solar right ascensions and declinations,
# split into years where each year starts near 0h and ends near 24h

require "/usr/local/lib/bclib.pl";

my($year) = 2000;

open(A, ">year-$year.txt");

while (<>) {

  my($observed, $unix, $jd, $ra, $dec, $ang) = split(/\s+/, $_);

#  debug("RA: $ra");

  if ($ra > $lastra) {
    print A $_;
    $lastra = $ra;
    next;
  }

  close(A);
  $year++;
  open(A, ">year-$year.txt");
  print A $_;
  $lastra = $ra;

}

# total lines in original: 21040849

# total lines in chunks: 21040849

