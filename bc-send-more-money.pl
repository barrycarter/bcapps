#!/bin/perl

# Brute force solves http://www.thelab.gr/xmas2011/auga.php and may
# serve as a template for similar problems

# The problem: HHBBBL + LEBBTL + LTLHEH = TH3L4B, with E=3

require "bclib.pl";

# TODO: nested loops are NOT the best way to do this, but they work
# letting E be a variable just for fun
for $try{H} (0..9) {
  for $try{B} (0..9) {
    for $try{L} (0..9) {
      for $try{T} (0..9) {
	for $try{E} (0..9) {
	  $sum = compute("HHBBBL") + compute("LEBBTL") + compute("LTLHEH");
	  $tot = compute("TH3L4B");
	  debug("SUM: $sum, TOT: $tot");
	}
      }
    }
  }
}


# given a string, compute its value using the 'try' hash
# TODO: no need to hardcode hash

sub compute {
  my($str) = @_;
  my($sum);
  # most significant digit first
  for $i (split(//, $str)) {
    $sum = $sum*10 + $i;
  }

  return $sum;
}
