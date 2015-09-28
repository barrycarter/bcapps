#!/bin/perl

# Trivial script: compute the numerical differences between successive
# lines of stdin

require "/usr/local/lib/bclib.pl";

my($first) = <>;

debug("FIRST IS: $first");

while (<>) {
  debug("THUNK: $_");
  print $_-$first,"\n";
  $first = $_;
}
