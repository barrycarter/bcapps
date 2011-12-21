#!/bin/perl

# Brute force solves http://www.thelab.gr/xmas2011/auga.php and may
# serve as a template for similar problems

# This program is dedicated to Christina Sereti (sereti at gmail dot com)

# The problem: HHBBBL + LEBBTL + LTLHEH = TH3L4B, with E=3

# solution: H=1, B=5, L=2, E=3, T=6 (appears to be unique)

# TODO: generalize (but problem not always trivial; search space is
# 10^(number of unique letters), assuming you allow for repeats)

# TODO: when search range is large, add --random option to search in
# random order?

# TODO: BIG: divine information about some letters from assigned
# values to others (eg, 2*L + H = B (mod 10) from last digits)

require "bclib.pl";

# digits map to themselves
for $i (0..9) {$temp{$i}=$i;}

# letting E be a variable just for fun

for $i ("00000".."99999") {
  @digits = split(//, $i);
  # assign digits to letters in this order
  for $j (split(//,"HBLTE")) {
    $temp{$j} = shift(@digits);
  }

  @sums = (compute("HHBBBL"), compute("LEBBTL"), compute("LTLHEH"));
  # NOTE: yes, there's a better way to do below
  $sum = $sums[0] + $sums[1] + $sums[2];
  $tot = compute("TH3L4B");
  debug("SUM: $sum, TOT: $tot");
  if ($sum == $tot && ++$count>1) {last;}
}

debug(@sums);

# given a string, compute its value using the 'temp' hash
# TODO: no need to hardcode hash

# TODO: couldve just changed letters to digits and returned, hmmm

sub compute {
  my($str) = @_;
  my($sum);
  # most significant digit first
  for $i (split(//, $str)) {
    $sum = $sum*10 + $temp{$i};
  }

  return $sum;
}
