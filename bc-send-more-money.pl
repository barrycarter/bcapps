#!/bin/perl

# Brute force solves http://www.thelab.gr/xmas2011/auga.php and may
# serve as a template for similar problems

# This program is dedicated to Christina Sereti (sereti at gmail dot com)

# The problem: HHBBBL + LEBBTL + LTLHEH = TH3L4B, with E=3



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
  if ($sum == $tot) {last;}
}

debug(@sums);

# given a string, compute its value using the 'try' hash
# TODO: no need to hardcode hash

sub compute {
  my($str) = @_;
  my($sum);
  # most significant digit first
  for $i (split(//, $str)) {
    $sum = $sum*10 + $temp{$i};
  }

  return $sum;
}
