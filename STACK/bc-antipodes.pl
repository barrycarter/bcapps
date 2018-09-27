#!/bin/perl

# attempts to solve
# https://earthscience.stackexchange.com/questions/14132/how-much-of-earths-land-area-has-antipodal-land-area
# using the 0.01 degree interpolation file and an attempt to read a
# file both backwards and forwards at the same time

require "/usr/local/lib/bclib.pl";

# NOTE: this file CAN NOT be compressed, since I am 'tac'ing it

open(A,"/home/user/20180807/output.asc");
open(B,"tac /home/user/20180807/output.asc|");

# the latitude of the top line
$lat = 90 - 0.01/2;


while (<A>) {

  # remove spaces
  s/^\s*//;

  # ignore header lines
  unless (/^\d/) {next;}


  

  $first = $_;
  $last = <B>;
  debug("$first vs $last");
}

