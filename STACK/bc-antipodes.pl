#!/bin/perl

# attempts to solve
# https://earthscience.stackexchange.com/questions/14132/how-much-of-earths-land-area-has-antipodal-land-area
# using the 0.01 degree interpolation file and an attempt to read a
# file both backwards and forwards at the same time

require "/usr/local/lib/bclib.pl";

# NOTE: this file CAN NOT be compressed, since I am 'tac'ing it

open(A,"/home/user/20180807/output.asc");
open(B,"tac /home/user/20180807/output.asc|");

# set skip to 1 for production
warn "SKIPPING!";
$skip = 100;

# the latitude of the top line
$lat = 90 - 0.01/2;
$row = 0;
$col = 0;

# the header for the fly file
print "new\nsize 36000,18000\nsetpixel 0,0,0,0,0\n";

# the colors for various combos
# array is signum-of-top signum-of-bottom

# TODO: make sure to include 0s, positive = water

$color{1}{1} = "0,0,255";
$color{1}{-1} = "0,255,0";
$color{-1}{1} = "255,255,0";
$color{1}{1} = "255,0,0";

# if this side is coastline, black, else gray

$color{0}{1} = "0,0,0";
$color{0}{-1} = "0,0,0";
$color{0}{0} = "0,0,0";

$color{1}{0} = "128,128,128";
$color{-1}{0} = "128,128,128";

while (<A>) {

  # remove spaces
  s/^\s*//;

  # ignore header lines
  unless (/^\d/) {next;}

  # get matching line from tac
  $rev = <B>;
  $rev=~s/^\s*//;

  # convert both to arrays
  my(@a) = split(/\s+/, $_);
  my(@b) = split(/\s+/, $rev);

  # 36000 elts per array (TODO: shouldn't hardcode this?)
  for ($i=0; $i<36000; $i+=$skip) {
    my($siga) = signum($a[$i]);
    my($sigb) = signum($b[($i+18000)%36000]);
    debug("$siga vs $sigb");
    print "setpixel $i,$row,$color{$siga}{$sigb}\n";
  }

  $row++;
  $col=0;
}

# fly -q -i antipodes.fly -o antipodes.gif
