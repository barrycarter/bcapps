#!/bin/perl

# Given data where the 5th column, $F[4], represents right ascension,
# print out same data, but make right ascension continuous by adding
# multiples of 2 pi as needed

require "/usr/local/lib/bclib.pl";

my($count) = 0;

while (<>) {

  my(@F) = split(/\s+/, $_);

  # in terms of mod 2*Pi, is new ra less than previous?

  debug($F[4]." ".fmodp($F[4], 2*$PI));

}

