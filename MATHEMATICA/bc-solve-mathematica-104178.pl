#!/bin/perl

# Parses http://physics.nist.gov/cuu/Constants/Table/allascii.txt

require "/usr/local/lib/bclib.pl";

# TODO: currently only using one list of constants but need more,
# since NIST doesn't include some of the constants in
# /usr/local/Wolfram/Mathematica/9.0/AddOns/Packages/PhysicalConstants/PhysicalConstants.m,
# such as EarthRadius (and probably many more)

# TODO: would adding AstronomicalData constants overload this?

while (<>) {
  my(@data) = column_data($_, [0,60,85,110,999]);

  # unless the first three fields are filled, we ignore
  unless ($data[0] && $data[1] && $data[2]) {
    debug("IGNORING: $_");
    next;
  }

  # trim data
  for $i (@data) {$i=~s/\s*$//;$i=~s/^\s*//;}

  my($name, $value, $uncert, $unit) = @data;

  # cleanup specific to fields
  $value=~s/\s//g;
  $value=~s/e/*10^/;
  $uncert=~s/\s//g;
  $uncert=~s/e/*10^/;

  debug("GOT: $name/$value/$uncert/$unit");
}

