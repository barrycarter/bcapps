#!/bin/perl

# Given a sorted list of numbers (backwards or forwards), reports gaps
# (presumably with the goal of finding largest/large gaps)

require "/usr/local/lib/bclib.pl";

while (<>) {
  debug("LAST2: $last");
  chomp();
  if ($last eq "") {$last = $_; next;}
  debug("LAST3: $last");
  $curr = $_;
  $diff = abs($curr-$last);
  debug("DIFF: $diff, $curr vs $last");
  if ($diff>1) {print "$last $diff\n";}
  $last = $curr;
  debug("LAST: $last");
}
