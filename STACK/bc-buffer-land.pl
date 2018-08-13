#!/bin/perl

# for some reason, Mathematica is having trouble with the signed
# distance-from-coast file from
# https://oceancolor.gsfc.nasa.gov/docs/distfromcoast/, so I am
# writing a Perl program to solve
# https://earthscience.stackexchange.com/questions/14656/how-to-calculate-boundary-around-all-land-on-earth
# instead

require "/usr/local/lib/bclib.pl";

my(%dist);

open(A, "bzcat /home/barrycarter/20180807/dist2coast.signed.txt.bz2|");

# warn "Random entries for testing";

while (<A>) {

#  if (rand() < .99) {next;}

  chomp;
  my($lon, $lat, $dist) = split(/\s+/, $_);

  # each entry represents .04 x .04 lat/lon square, so size is
  # dependent on cosine of latitude (in degrees)
  my($area) = cos($lat*$DEGRAD);
  # hideous double use of dist as hash and scalar
  # also hideous using real value as key
  $dist{$dist} += $area;

  # just a counter
  if (++$count%100000==0) {debug("COUNT: $count");}

}

my($accum) = 0;

for $i (sort {$a <=> $b} keys %dist) {
  $accum += $dist{$i};
  print "$i $dist{$i} $accum\n";
}
