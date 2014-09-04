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
my($arraynum, $arraylength, $count, $ctime, $duration);

while (<A>) {

  # raw 1024 ignore so often, I want to ignore them early and quietly
  if (/^1024$/) {next;}

  # start of new array?
  if (/BEGIN_ARRAY\s+(\d+)\s+(\d+)$/) {
    ($arraynum, $arraylength) = ($1,$2);
    open(B,">/tmp/xsp2math-$fname-array-$arraynum.m");
    print B "coeffs = {\n";
    $count = 0;
    next;
  }

  if (/END_ARRAY\s+(\d+)\s+(\d+)$/) {
    # to avoid "last comma" issue, add artificial 0 to end of array
    print B "0};\n";
    close(B);
    next;
  }

#  if ($arraynum>3) {warn "TESTING"; last;}

  # ignore anything not in DAF form
  unless (/^\'(\-?)([0-9A-F]+)\^(\-?(\d+))\'$/) {
    warn("IGNORING: $_");
    next;
  }

  # which element of array are we looking at? (the first 4 elts are special)
  $count++;

  # the first two elements just give the integration interval, which
  # is uninteresting to us
  if ($count<=2) {next;}

  my($sgn,$mant,$exp) = ($1,$2,$3);
  my($pow) = $exp-length($mant);
  my($num) = hex($mant)*16**$pow;
  if ($sgn eq "-") {$num*=-1;}

  # elements 3 and 4 are the center time + duration of this sub-array
  if ($count==3) {$ctime = $num; next;}
  # when we have the 4th element, calculate start time of next sub-array
  if ($count==4) {
    $duration = $num;
    $narray = $ctime+2*$duration;
    debug("CTD: $ctime/$duration/$narray");
    next;
  }

#  debug("ALPHA: $ctime/$duration/$narray");

  # have we found the start of the next subarray?
  if ($num == $narray) {
    # reset $count (this is ugly!!!) so the next two numbers become
    # the new ctime an duration
    # TODO: this is really ugly!
    $count = 3;
    $ctime = $num;
    next;
  }

#  debug("NARRAY: $narray");
#  debug("$count: $num");
  # TODO: extra comma?
  print B qq%${sgn}FromDigits["$mant",16]*16^$pow,\n%;
#  debug("$sgn:$mant:$exp:$num");

}
