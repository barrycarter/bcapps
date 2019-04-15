#!/bin/perl

# Converts the 129600x64800 file from
# http://maps.elie.ucl.ac.be/CCI/viewer/download.php to a binary file;
# I'd normally use sequential values but ESACCI-LC-Legend.csv is a
# legend and I am using it

require "/usr/local/lib/bclib.pl";

# smaller file for testing

# warn "TESTING";
# open(A, "convert /home/barrycarter/NOBACKUP/EARTHDATA/LANDUSE/lcc_global_8192.tif txt:- |");

# read the legend file

my($legend) = read_file("$bclib{githome}/MAPS/ESACCI-LC-Legend.csv");

my(%legend);

for $i (split(/\n/, $legend)) {
  # to get rid of crlf at end
  $i=~s/\s*$//g;
  my($val, $desc, $r, $g, $b) = split(/\;/, $i);
  $legend{"$r,$g,$b"} = $val;
  debug("$r $g $b");
}

# debug(%legend);

# file is too big for git (312.7 MB)

# it would be cool to do things this way, but unfortunately too slow (over 60 seconds to open), so I'll used the fixed txt conversion I have instead

# open(A, "convert /home/barrycarter/NOBACKUP/EARTHDATA/LANDUSE/ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7.tif txt:- |");

open(A, "bzcat /home/barrycarter/NOBACKUP/EARTHDATA/LANDUSE/ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7.txt.bz2|");

while (<A>) {

  # if there is a triplet, despace it and decode it
  unless (s/\(([\s\d\,]+)\)//) {
    warn "BAD LINE: $_";
    next;
  }

  my($color) = $1;
  $color=~s/\s//;

  debug("GOT: $color -> $legend{$color}");
}
