#!/bin/perl

# converts XSP files for use with Mathematica, and tries to be a
# little clever about it

require "/usr/local/lib/bclib.pl";

# TODO: required to avoid "Integer overflow in hexadecimal number",
# but do this better somehow
no warnings;

# TODO: this is a test file
my($fname) = @ARGV;
open(A,"$homedir/SPICE/KERNELS/$fname.xsp");
my($temp);

while (<A>) {

  # raw 1024 ignore so often, I want to ignore them early and quietly
  if (/^1024$/) {next;}

  # start of new array?
  if (/BEGIN_ARRAY\s+(\d+)\s+(\d+)$/) {
    ($arraydata{num}, $arraydata{length}) = ($1,$2);

    # read the first few lines which are special
    # x1/x2/x3 uninteresting for now
    for $i ("name", "jdstart", "jdend", "objid", "x1", "x2", "x3", "startsec",
	   "secs") {
      # avoid 1024
      $temp = <A>;
      if ($temp=~/^1024$/) {$temp=<A>;}
      $temp = ieee754todec($temp);
      debug("$i -> $temp");
      $arraydata{$i} = $temp;
    }

    # the body id (it's not in IEEE-754 format, so not caught above)
    $arraydata{objid} = hex($arraydata{objid});

    # record next interval midpoint so we can ignore it later
    $nextint = $arraydata{startsec}+2*$arraydata{secs};

    # TODO: check if output file already exists
    open(B,">$homedir/SPICE/KERNELS/MATH/xsp2math-$fname-array-$arraydata{objid}.m");
    print B "coeffs = {\n";
    next;
  }

  if (/END_ARRAY\s+(\d+)\s+(\d+)$/) {
    # to avoid "last comma" issue, add artificial 0 to end of array
    print B "0};\n";
    close(B);
    next;
  }

  $num = ieee754todec($_);
  if ($num eq $_) {warn "NO CHANGE: $num, ignoring"; next;}

  # are we seeing the next interval? If so, ignore 2 lines and reset nextint
  if ($num eq $nextint) {
    # read the next line and reset nextint
    $temp = <A>;
    $nextint += 2*ieee754todec($temp);
    next;
  }

  print B ieee754todec($_,"mathematica=1"),",\n";

}

=item ieee754todec($str,$options)

Converts $str in IEEE-754 format to decimal number. If $str is not in
IEEE-754 format, return it as is (however, is $str is
apostrophe-quoted, will remove apostrophes)

WARNING: Perl does not have sufficient precision to do this 100% correctly.

Options:

mathematica=1: return in Mathematica format (exact), not decimal

=cut

sub ieee754todec {
  my($str,$options) = @_;
  my(%opts) = parse_form($options);

  $str=~s/\'//g;
  unless ($str=~/^(\-?)([0-9A-F]+)\^(\-?([0-9A-F]+))$/) {return $str;}
  my($sgn,$mant,$exp) = ($1,$2,hex($3));
  my($pow) = $exp-length($mant);

  # for mathematica, return value is easy
  if ($opts{mathematica}) {return qq%${sgn}FromDigits["$mant",16]*16^$pow%;}

  # now the "real" (haha) value
  my($num) = hex($mant)*16**$pow;
  if ($sgn eq "-") {$num*=-1;}
  return $num;
}

