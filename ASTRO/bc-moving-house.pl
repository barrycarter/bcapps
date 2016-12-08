#!/bin/perl

# parses houses.txt.bz2 to provide "horoscope" changes

require "/usr/local/lib/bclib.pl";

%state = ("S" => 1, "M" => 3, 1 => 1, 2 => 2, 4 => 2, 5 => 1, 6 => 6);

open(A, "bzcat houses.txt.bz2|");

while (<A>) {
  my(@f) = split(/\s+/, $_);
  debug("$f[0] $f[6] $f[7]");
#  debug("GOT: $_");
}
