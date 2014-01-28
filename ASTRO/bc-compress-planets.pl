#!/bin/perl

require "/usr/local/lib/bclib.pl";

# compresses the planet Chebyshev files to make them more compact

debug(f16218d("-0.7911704670057320D+06"));

# debug(d1225b(726429257383));



# converts a 12-digit string of digits to a string of 5 bytes (not useful in
# general, just for this program)

sub d122b5 {
  my($num) = @_;
  my($str);
  for $i (0..4) {$str.=chr($num/256**$i%256);}
  # I dislike LSB, so flipping string
  return reverse($str);
}

# given a 16-digit-precision signed number in Fortran form with signed
# exponent from -11..+11, (like -0.7911704670057320D-06) return an
# 18-digit number representing it

sub f162d18 {
  my($str) = @_;

  unless ($str=~/^(\-?)0\.(\d{16})D(\+|\-)(\d{2})$/) {
    warn ("BAD STR: $str");
    return;
  }

  # extract signs, mantissa and exponent
  my($s1,$ma,$s2,$ex) = ($1,$2,$3,$4);

  # 16 digits of mantissa + exponent + 0, 25, 50, 75
  # add 50 if $s1 is negative, another 25 if $s2 is
  if ($s1 eq "-") {$ex+=50;}
  if ($s2 eq "-") {$ex+=25;}
  return "$ma$ex";
}
