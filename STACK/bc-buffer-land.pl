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

# the latitude of the top line
$lat = 90 - 0.01/2;

open(A, "bzcat /home/barrycarter/20180807/output.asc.bz2|");

while (<A>) {

  chomp;

  # remove spaces
  s/^\s*//;

  # ignore header lines
  unless (/^\d/) {next;}

  # since the latitude is constant for the row, area is fixed for all cols
  # spherical approximation from:
  # http://mathforum.org/library/drmath/view/63767.html

  my($area) = 6371.008*6371.008/36000*2*$PI*
 (sin($DEGRAD*($lat+0.01/2)) - sin(($DEGRAD*($lat-0.01/2))));
  debug("LAT: $lat, AREA: $area");

  for $i (split(/\s+/, $_)) {
    $totarea += $area;
#    debug("LAT: $lat, I: $i");
  }

  $lat -= 0.01;

}

debug("TOTAREA: $totarea");

=item comment


  my($lon, $lat, $dist) = split(/\s+/, $_);

  # each entry represents .04 x .04 lat/lon square, so size is
  # dependent on cosine of latitude (in degrees)
  my($area) = cos($lat*$DEGRAD);
  # hideous double use of dist as hash and scalar
  # also hideous using real value as key
  $dist{$dist} += $area;

}

my($accum) = 0;

for $i (sort {$a <=> $b} keys %dist) {
  $accum += $dist{$i};
  print "$i $dist{$i} $accum\n";
}

=cut
