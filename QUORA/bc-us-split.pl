#!/bin/perl

# Does things with US county data

# TODO: see .m version of this file

# TODO: what does "Created for statistical purposes only." mean? is my
# use invalid? (if so, get from Mathematica shape data or something)

require "/usr/local/lib/bclib.pl";

counties2db();

# add counties to mysql db
sub counties2db {

  local(*A);
  open(A,"bzcat $bclib{githome}/QUORA/Gaz_counties_national.txt.bz2|")||die("Can't open, $!");

  while (<A>) {
    my(@tsv) = split(/\t/, $_);
    debug(@tsv);
  }
}

=item comment

CREATE TABLE counties (
 

Column 1USPS United States Postal Service State Abbreviation
  Column 2GEOID Geographic Identifier - fully concatenated geographic code (State FIPS and County FIPS)
  Column 3 ANSICODE American National Standards Institute code
  Column 4NAME Name
  Column 5 POP10 2010 Census population count.
  Column 6 HU10 2010 Census housing unit count.
  Column 7ALAND Land Area (square meters) - Created for statistical purposes only.
  Column 8AWATER Water Area (square meters) - Created for statistical purposes only.
  Column 9ALAND_SQMI Land Area (square miles) - Created for statistical purposes only.
  Column 10AWATER_SQMI Water Area (square miles) - Created for statistical purposes only.
  Column 11INTPTLAT Latitude (decimal degrees) First character is blank or "-" denoting North or South latitude respectively.
  Column 12 INTPTLONG Longitude (decimal degrees) First character is blank or "-" denoting East or West longitude respectively.

=end
