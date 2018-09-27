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
$row = 0;
$col = 0;

# The Earth's surface area (to excessive precision)
$surfEarth = 5.10065621721675*10**8;

# the header for the fly file
print "new\nsize 36000,18000\nsetpixel 0,0,0,0,0\n";

# the colors for various combos
# array is signum-of-top signum-of-bottom

# TODO: make sure to include 0s, positive = water

$color{1}{1} = "0,0,255";
$color{1}{-1} = "0,255,0";
$color{-1}{1} = "255,255,0";
$color{-1}{-1} = "255,0,0";

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

  my($area) = $surfEarth/36000/2*
 (sin($DEGRAD*($lat+0.01/2)) - sin(($DEGRAD*($lat-0.01/2))));

  # 36000 elts per array (TODO: shouldn't hardcode this?)
  for ($i=0; $i<36000; $i++) {
    my($siga) = signum($a[$i]);
    my($sigb) = signum($b[($i+18000)%36000]);
    $area{$siga}{$sigb} += $area;
    debug("$siga vs $sigb");
    print "setpixel $i,$row,$color{$siga}{$sigb}\n";
  }

  $lat -= 0.01;
  $row++;
  $col=0;

#  if ($row > 500) {warn "TESTING"; last;}

}

for $i (-1,0,1) {
  for $j (-1,0,1) {
    print "AREA{$i}{$j} = $area{$i}{$j}\n";
  }
}

# fly -q -i antipodes.fly -o antipodes.gif

=item results

AREA{-1}{-1} = 19906710.7467257
AREA{-1}{0} = 297688.331872441
AREA{-1}{1} = 128169517.66609
AREA{0}{-1} = 297688.331872657
AREA{0}{0} = 1250.38289195193
AREA{0}{1} = 653131.809793994
AREA{1}{-1} = 128169517.670194
AREA{1}{0} = 653131.809794171
AREA{1}{1} = 231916984.984719

=cut
