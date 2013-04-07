#!/bin/perl

# Generates "all possible" formats for a given time spec to test bc-timer plugin

require "/usr/local/lib/bclib.pl";

# need these in order (sort of) [not bothering w centuries]
@times=split(//,"YmUdHMS");

# TODO: maybe subroutinize this
# clever way to find all subsets w/o multiple for loops
# intentionally omitting 0 as it would represent the empty set
for $i (1..2**($#times+1)) {
  # TODO: more efficient way to see which bits are 'lit'?
  @list = ();
  for $j (0..$#times) {
    # intentional use of bitand below
    if ($i & 2**$j) {
      debug("LIT: $j in $i");
      push(@list, $times[$j]);
    }
  }
  push(@power, [@list]);
}

debug(@power);

