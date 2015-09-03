#!/bin/perl

# The ascp files I created for planet positions are named like:
# ascp02000.431.bz2.mercury,venus,earthmoon,mars,jupiter,saturn,uranus,sun.mx
# where as the mseps files are named like:
# mseps-2451536-2816816.mx

# This script unifies the two and prints out commands to create a
# conjunctions database (pipe to shell for anything to actually happen)

# modified slightly 3 Sep 2015 to create annotated conjunction files

require "/usr/local/lib/bclib.pl";

for $i (glob "/home/barrycarter/SPICE/KERNELS/truemseps-*") {
  $i=~m%mseps-(\-?\d+)%;
  my($jd) = $1;

  # convert to nearest millenium
  my($file) = sprintf("/home/barrycarter/SPICE/KERNELS/ascp%05d.431.bz2.mercury,venus,earthmoon,mars,jupiter,saturn,uranus,sun.mx",abs(1000*round($jd/365.2425/1000-4.712)));

  # and negative years
  if ($jd<1721040) {$file=~s/p/m/;}

  unless (-f $file) {warn "NO SUCH FILE: $file";}

  # and the command that will find the true min separations
  print "math -initfile $i -initfile $file < /home/barrycarter/BCGIT/ASTRO/bc-trueseps2final.m\n";

}

exit();

for $i (glob "/home/barrycarter/SPICE/KERNELS/mseps-*") {
  $i=~m%mseps-(\-?\d+)%;
  my($jd) = $1;

  # convert to nearest millenium
  my($file) = sprintf("ascp%05d.431.bz2.mercury,venus,earthmoon,mars,jupiter,saturn,uranus,sun.mx",abs(1000*round($jd/365.2425/1000-4.712)));

  # and negative years
  if ($jd<1721040) {$file=~s/p/m/;}

  unless (-f $file) {warn "NO SUCH FILE: $file";}

  # and the command that will find the true min separations
  print "math -initfile $i -initfile $file < /home/barrycarter/BCGIT/ASTRO/bc-conjunct-final.m\n";

}

