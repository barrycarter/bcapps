#!/bin/perl

require "/usr/local/lib/bclib.pl";

# compresses the planet Chebyshev files to make them more compact

debug(d1225b(726429257383));

# converts a 12-digit integer to a string of 5 bytes (not useful in
# general, just for this program)

sub d1225b {
  my($num) = @_;
  my($str);
  for $i (0..4) {$str.=chr($num/256**$i%256);}
  # I dislike LSB, so flipping string
  return reverse($str);
}
