#!/bin/perl

require "/usr/local/lib/bclib.pl";

# attempts to rewrite XSP files in uber-compact format, broken down by
# center and object, but wo losing any precision

my(%hash, $chunk, @arr, $count);

# TODO: genericize
open(A,"$bclib{home}/SPICE/KERNELS/jup310.xsp");

while (<A>) {

  chomp($_);

  # ignore pure numbers
  if (/^\d+$/) {next;}

  # if beginning of array, do special things
  if (/BEGIN_ARRAY\s+(\d+)\s+(\d+)$/) {

    # close existing file (if any)
    close(B);

    # array number and size
    ($hash{num}, $hash{rsize}) = ($1,$2);

    # other data on this array (start_sec is intentionally overwritten below)
    for $i ("name", "start_sec", "end_sec", "target", "center", "ref_frame",
	    "eph_type", "start_sec", "interval") {

      # have to ignore pure numbers here too, ugly
      do {$chunk=scalar(<A>)} until ($chunk!~/^\d+$/);
      chomp($chunk);

      # we need these in pure form too
      $hash{"pure_$i"} = $chunk;
      $hash{$i} = ieee754todec($chunk);
    }

    # how many coefficients per coordinate?
    # number of intervals (rounded down since end_sec is really end of
    # integration second)
    $hash{nint} = floor(($hash{end_sec}-$hash{start_sec})/$hash{interval}/2);
    # coefficients per interval (-2 because first two entries arent coeffs)
    $hash{cpi} = floor($hash{rsize}/$hash{nint})-2;

    # open next file and write start date and interval
    open(B,">/home/barrycarter/SPICE/KERNELS/test-$hash{target}-$hash{center}.bsp");
    for $j ("pure_start_sec", "pure_interval") {
      print B ieee754todec($hash{$j}, "binary=1")
    }

    # TODO: assuming cpi <= 255 is bad
    print B chr($hash{cpi});

    next;
  }

  # if we haven't seen an array yet, do nothing
  unless ($hash{num}) {next;}

  push(@arr, $_);

  # if array isn't full yet, keep going
  if (scalar(@arr) < $hash{cpi}+2) {next;}

  # array is full: first, drop last two values (midtime+interval)
  pop(@arr); pop(@arr);

  # if $eph_type is 3, we only want the first half of the array (the
  # rest is vx vy vz which is redundant)
  if ($hash{eph_type} == 3) {@arr = @arr[0..(scalar(@arr)-1)/2];}

  # now, write to file
  @arr = map($_=ieee754todec($_,"binary=1"), @arr);

  print B join("",@arr);

  # and reset @arr
  @arr = ();

}

close(B);

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
