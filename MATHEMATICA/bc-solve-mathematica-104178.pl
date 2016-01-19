#!/bin/perl

# Parses http://physics.nist.gov/cuu/Constants/Table/allascii.txt

require "/usr/local/lib/bclib.pl";

# TODO: currently only using one list of constants but need more,
# since NIST doesn't include some of the constants in
# /usr/local/Wolfram/Mathematica/9.0/AddOns/Packages/PhysicalConstants/PhysicalConstants.m,
# such as EarthRadius (and probably many more)

# TODO: ultimately create a package

# TODO: would adding AstronomicalData constants overload this?

my($valid) = 0;

while (<>) {
  my(@data) = column_data($_, [0,60,85,110,999]);

  # ignore up to line of hyphens
  if (/^\-{20}/) {$valid = 1; next;}
  unless ($valid) {next;}

  # trim data
  for $i (@data) {$i=~s/\s*$//;$i=~s/^\s*//;}

  my($name, $value, $uncert, $unit) = @data;

  # cleanup specific to fields
  $value=~s/\s//g;
  $value=~s/e/*10^/;
  $uncert=~s/\s//g;
  if ($uncert eq "(exact)") {$uncert = 0;} else {$uncert=~s/e/*10^/;}
  $unit=~s/ /\*/g;

  # unitless
  if ($unit=~/^\s*$/) {$unit = "1";}

  print qq%physicalConstant["$name"] = {$value,$uncert,$unit};\n%;

  debug("GOT: $name/$value/$uncert/$unit");
}

