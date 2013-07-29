#!/bin/perl

# Given a sorted list of numbers (backwards or forwards), reports gaps
# (presumably with the goal of finding largest/large gaps)

require "/usr/local/lib/bclib.pl";

while (<>) {
  chomp();
  if ($last eq "") {$last = $_; next;}
  $curr = $_;
  $diff = abs($curr-$last);
  if ($diff>1) {print "$last $diff\n";}
  $last = $curr;
}
