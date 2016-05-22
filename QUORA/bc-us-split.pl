#!/bin/perl

# Does things with US county data

# TODO: see .m version of this file

# TODO: what does "Created for statistical purposes only." mean? is my
# use invalid? (if so, get from Mathematica shape data or something)

require "/usr/local/lib/bclib.pl";

my($tots) = sqlite3hashlist("SELECT SUM(pop10) AS popt, 
 SUM(aland+awater) AS areat FROM counties
 WHERE usps NOT IN ('PR', 'AK', 'HI')", "$bclib{githome}/QUORA/counties.db");

my($popt, $areat) = ($tots->{popt}, $tots->{areat});

debug(": $popt $areat");

# given a line slope and intercept, return the percentage amount of
# land and population below that line

# NOTE: uses globals, not a true subroutine and not intended to be

sub pop_area_below_line {
  my($m,$b) = @_;

  my($q) = sqlite3hash("SELECT SUM(pop10)/$popt AS popt,
  SUM(aland+awater)/$areat AS areat FROM counties WHERE usps NOT IN
  ('PR', 'AK', 'HI') AND intptlat < $m*intptlon + $b");

  debug("$q->{popt}, $q->{areat}");
}

=item queries

SELECT SUM(pop10) FROM counties WHERE usps NOT IN ('PR', 'AK', 'HI');

is 306675006

SELECT SUM(aland+awater) FROM counties WHERE 
 usps NOT IN ('PR', 'AK', 'HI');

is 8081867092450

SELECT SUM(pop10), SUM(aland+awater) FROM counties WHERE 
 usps NOT IN ('PR', 'AK', 'HI')
AND intptlat < 40;

is surprisingly close!

TODO: straight line vs geodesic (merctaor, no such thing)

TODO: mention gis.stack answer

=end


=item comment

CREATE TABLE counties (
 usps TEXT, geoid TEXT, ansicode TEXT, name TEXT,
 pop10 INT, hu10 INT, aland DOUBLE, awater DOUBLE,
 aland_sqmi DOUBLE, awater_sqmi DOUBLE,
 intptlat DOUBLE, intptlong DOUBLE
);

; sqlite3 below
.separator \t
; fun fact: if you add ";" to below, it fails
.import "/home/barrycarter/20160522/Gaz_counties_national.txt" counties

LOAD DATA INFILE
"/home/barrycarter/20160522/Gaz_counties_national.txt" INTO TABLE counties;

; delete the header row
DELETE FROM counties WHERE usps='USPS';

; without PR evaluates to
; https://en.wikipedia.org/wiki/2010_United_States_Census exactly

; with PR searching for 312471327 yields some results

checks (and balances I suppose):

SELECT SUM(pop10) FROM counties;
+------------+
| SUM(pop10) |
+------------+
|  312471327 | 
+------------+

SELECT SUM(aland+awater) FROM counties;
+-------------------+
| SUM(aland+awater) |
+-------------------+
|     9847308090685 | 
+-------------------+

SELECT SUM(aland+awater) FROM counties WHERE usps NOT IN ('PR');

TODO: my numbers dont quite add up, maybe mention what I get vs official sources

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
