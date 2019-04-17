#!/bin/perl

# Converts the 129600x64800 file from
# http://maps.elie.ucl.ac.be/CCI/viewer/download.php to a binary file;

# in the gray scale version, I just copy bytes

require "/usr/local/lib/bclib.pl";

# TIFF file is too big for git (312.7 MB), conversion to txt is 11 GB
# (bzip2 compressed!)

open(A, "bzcat /home/barrycarter/NOBACKUP/EARTHDATA/LANDUSE/ESACCI-LC-L4-LCCS-Map-300m-P1Y-2015-v2.0.7.txt.bz2|");

while (<A>) {

  # if there is a triplet, despace it and decode it
  unless (s/\(([\s\d]+),\1,\1\)//) {
    warn "BAD LINE: $_";
    next;
  }

  my($color) = $1;
  print chr($color);
}

