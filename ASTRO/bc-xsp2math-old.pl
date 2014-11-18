#!/bin/perl

# This is an older version of bc-xsp2math (modified) to spit out
# coefficients after I fix ieee754todec

# converts XSP files for use with Mathematica, and tries to be a
# little clever about it

require "/usr/local/lib/bclib.pl";

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

    # record next interval midpoint so we can ignore it later
    $nextint = $arraydata{startsec}+2*$arraydata{secs};

    debug("DATA",%arraydata);
    die "ALPHA TESTING";

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

  my($val) = ieee754todec($_,"mathematica=1").",\n";

  # silly fix so I can compare to older (incorrect) files
  $val=~s/^1\*//;
  $val=~s/^\-1\*/-/;

  print B $val;

}
