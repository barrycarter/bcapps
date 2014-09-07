#!/bin/perl

# converts XSP files for use with Mathematica, and tries to be a
# little clever about it

require "/usr/local/lib/bclib.pl";

# TODO: required to avoid "Integer overflow in hexadecimal number",
# but do this better somehow
no warnings;

# TODO: this is a test file
$fname = "sat365";
open(A,"/home/barrycarter/SPICE/KERNELS/$fname.xsp");
my($temp);

while (<A>) {
  chomp;

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

      $temp=~s/\'//g;
      $temp = ieee754todec($temp);
      debug("$i -> $temp");
      $arraydata{$i} = $temp;
    }

    # the body id (it's not in IEEE-754 format, so not caught above)
    $arraydata{objid} = hex($arraydata{objid});

    open(B,">/home/barrycarter/SPICE/KERNELS/MATH/xsp2math-$fname-array-$arraydata{objid}.m");
    print B "coeffs = {\n";
    next;
  }

  if (/END_ARRAY\s+(\d+)\s+(\d+)$/) {
    # to avoid "last comma" issue, add artificial 0 to end of array
    print B "0};\n";
    close(B);
    next;
  }

  # ignore anything not in DAF form
  unless (/^\'(\-?)([0-9A-F]+)\^(\-?([0-9A-F]+))\'$/) {
    warn("IGNORING: $_");
    next;
  }

  # we need to do this twice, once for Mathematica, and once for this script

  # are we seeing the next "chunk"?
  debug("GOT",ieee754todec($_));

  next;warn "TESTING";


  my($sgn,$mant,$exp) = ($1,$2,hex($3));
  my($pow) = $exp-length($mant);
  my($num) = hex($mant)*16**$pow;
  if ($sgn eq "-") {$num*=-1;}

  print B qq%${sgn}FromDigits["$mant",16]*16^$pow,\n%;
}

=item ieee754todec($str,$options)

Converts $str in IEEE-754 format to decimal number. If $str is not in
IEEE-754 format, return it as is.

WARNING: Perl does not have sufficient precision to do this 100% correctly.

Options:

mathematica=1: return in Mathematica format (exact), not decimal

=cut

sub ieee754todec {
  my($str) = @_;
  debug("GOT: $str");
  unless ($str=~/^(\-?)([0-9A-F]+)\^(\-?([0-9A-F]+))$/) {return $str;}

  my($sgn,$mant,$exp) = ($1,$2,hex($3));

  # TODO: implement mathematica option!

  my($pow) = $exp-length($mant);
  my($num) = hex($mant)*16**$pow;
  if ($sgn eq "-") {$num*=-1;}
  return $num;
}

