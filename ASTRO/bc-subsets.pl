#!/bin/perl

# trivial script to find all subsets of planets (1,2,4,5,6,7) that
# have at least two members; only clever thing is I don't use 6 for
# loops

require "/usr/local/lib/bclib.pl";

my(@p) = (1,2,4,5,6,7);

for $i (0..2**scalar(@p)-1) {
  my(@sub) = ();

  # bit and!
  for $j (0..$#p) {if($i&2**$j){push(@sub,$p[$j]);}}

  if (scalar(@sub)<2) {next;}
  print join(" ",@sub),"\n";
}
