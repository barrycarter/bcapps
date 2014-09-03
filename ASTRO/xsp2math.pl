#!/bin/perl

# converts XSP files for use with Mathematica, and tries to be a
# little clever about it

require "/usr/local/lib/bclib.pl";

# TODO: required to avoid "Integer overflow in hexadecimal number",
# but do this better somehow
no warnings;

# TODO: this is a test file
open(A,"/home/barrycarter/SPICE/KERNELS/sat365.xsp");
my($arraynum, $arraylength);

# write to math file
open(B,">/tmp/xsp2math.m");

while (<A>) {

  # raw 1024 ignore so often, I want to ignore them early and quietly
  if (/^1024$/) {next;}

  # start of new array?
  if (/BEGIN_ARRAY\s+(\d+)\s+(\d+)$/) {
    ($arraynum, $arraylength) = ($1,$2);
    # open new array (could do array as a true list, but nah)
    print B "array$arraynum = {\n";
    next;
  }

  if (/END_ARRAY\s+(\d+)\s+(\d+)$/) {
    # to avoid "last comma" issue, add artificial 0 to end of array
    print B "0};\n";
    next;
  }

  if ($arraynum>3) {warn "TESTING"; last;}

  # ignore anything not in DAF form
  unless (/^\'(\-?)([0-9A-F]+)\^(\-?(\d+))\'$/) {
    warn("IGNORING: $_");
    next;
  }

  my($sgn,$mant,$exp) = ($1,$2,$3);
  my($pow) = $exp-length($mant);
  my($num) = hex($mant)*16**$pow;
  # TODO: extra comma?
  print B qq%FromDigits["$mant",16]*16^$pow,\n%;
  debug("$sgn:$mant:$exp:$num");

}
