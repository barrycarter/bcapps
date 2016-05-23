#!/bin/perl

# The file blockgroups.txt.bz2 is a bzip2'd version of the output of:
# ogrinfo -sql "SELECT * FROM ACS_2014_5YR_BG" ACS_2014_5YR_BG.gdb.zip |
# fgrep -v MULTIPOLYGON
# where ACS_2014_5YR_BG.gdb.zip is the 1.5G file found at:
# https://www.census.gov/geo/maps-data/data/tiger-data.html
# under "2010 - 2014 Detailed Tables", choosing "Block Group" and then
# "National File". Direct link to this 1.5G file: 
# http://www2.census.gov/geo/tiger/TIGER_DP/2014ACS/ACS_2014_5YR_BG.gdb.zip

# this program parses that output (blockgroups.txt.bz2) into sqlite3
# format to help solve:
# https://www.quora.com/If-California-were-to-be-divided-in-half-using-a-horizontal-straight-line-with-one-half-of-the-population-on-each-side-where-would-that-line-be
# and related questions

# there are 220333 features total

require "/usr/local/lib/bclib.pl";

open(A,"bzcat $bclib{githome}/QUORA/blockgroups.txt.bz2|");

# first 36 lines are useless to me
for (1..36) {<A>};

# fun fact: sqlite3 will auto-create a table from the header row when
# using .import; however, this isn't particularly useful in this case

print join("\t", ("STATEFP", "COUNTYFP", "TRACTCE", "BLKGRPCE",
"GEOID", "NAMELSAD", "MTFCC", "FUNCSTAT", "ALAND", "AWATER",
"INTPTLAT", "INTPTLON", "Shape_Length", "Shape_Area",
"GEOID_Data", "Blank")),"\n";


for $i (1..220333) {

  # check header
  unless (<A> eq "OGRFeature(ACS_2014_5YR_BG):$i\n") {die("BAD HEADER!");}
  my(@l) = ($i);
  for $j(1..16){if (<A>=~/\s*(.*?)\s*\((.*?)\)\s*\=\s*(.*?)$/) {push(@l,$3);}}
  print join("\t",@l),"\n";
}

=item schema

.separator \t
.import /home/barrycarter/CENSUS/blockgroups-import.txt blockgroups

=end
