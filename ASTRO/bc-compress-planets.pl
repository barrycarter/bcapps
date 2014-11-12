#!/bin/perl

require "/usr/local/lib/bclib.pl";

# attempts to rewrite XSP files in uber-compact format, broken down by
# center and object, but wo losing any precision

my(%hash);
my($chunk);

# TODO: genericize
open(A,"$bclib{home}/SPICE/KERNELS/jup310.xsp");

while (<A>) {
  debug("ALPHA: $_");

  # ignore pure numbers
  if (/^\d+$/) {next;}

  # if beginning of array, do special things
  if (/BEGIN_ARRAY\s+(\d+)\s+(\d+)$/) {

    # array number and size
    ($hash{num}, $hash{rsize}) = ($1,$2);

    # other data on this array (start_sec is intentionally overwritten below)
    for $i ("name", "start_sec", "end_sec", "target", "center", "ref_frame",
	    "eph_type", "start_sec", "interval") {
      # have to ignore pure numbers here too, ugly
      do {$chunk=scalar(<A>)} until ($chunk!~/^\d+$/);
      $hash{$i} = ieee754todec($chunk);
    }

    # how many coefficients per coordinate?
    # number of intervals (rounded down since end_sec is really end of
    # integration second)
    $hash{nint} = floor(($hash{end_sec}-$hash{start_sec})/$hash{interval}/2);
    # coefficients per interval (-2 because first two entries arent coeffs)
    $hash{cpi} = floor($hash{rsize}/$hash{nint})-2;
    # if this is eph_type 3, we ignore the useless vx/vy/vz components
#    if ($hash{eph_type}==3) {$hash{cpi}=floor($hash{cpi}/2);}
    debug("HASH",%hash);

    next;
  }

  # if we haven't seen an array yet, do nothing
  unless ($hash{num}) {next;}

  debug("GOT: $_");

}


debug(%hash);


die "TESTING";


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

# TODO: move this bclib.pl

=item td(@list)

Transparent debugging: print @list to stderr and return it.

=cut

sub td {
  my(@list) = @_;
  debug("TRANSDEBUG:",@list);
  return @list;
}
