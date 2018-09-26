#!/bin/perl

# https://earthscience.stackexchange.com/questions/14656/how-to-calculate-boundary-around-all-land-on-earth

# Mathematica is very slow with the
# GMT_intermediate_coast_distance_01d.zip file on
# https://oceancolor.gsfc.nasa.gov/docs/distfromcoast/ probably
# because it tries to load the whole thing into memory

# So I instead ran:
# gdal_translate -of AAIGrid GMT_intermediate_coast_distance_01d.tif output.asc
# bzip2 output.asc
# in another directory (output.asc.bz2 is still too large for github)
# and will now parse it for area using Perl

# I did use Mathematica to create the raster maps, however

require "/usr/local/lib/bclib.pl";

my(%dist);

open(A, "bzcat /home/barrycarter/20180807/output.asc.bz2|");

while (<A>) {

  chomp;

  debug("GOT LINE: $_");

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
