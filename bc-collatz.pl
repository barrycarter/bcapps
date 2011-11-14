#!/bin/perl

# thoughts on the Collatz conjection
require "bclib.pl";

for $i (1..100) {
  # the first 100 odd numbers
  $n = 2*$i+1;
  $x = $n;

  # find the first odd image
  do {
    if ($n%2==0) {$n/=2;} else {$n=3*$n+1;}
    } until ($n%2==1);

  print "$x -> $n\n";
}

