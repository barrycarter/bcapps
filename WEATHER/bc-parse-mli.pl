#!/bin/perl

# Parses master-location-identifier-database-20130801.csv which
# contains a few (albeit very few) stations that neither nsd nor ucar
# has

require "/usr/local/lib/bclib.pl";


for $i (split(/\n/,read_file("master-location-identifier-database-20130801.csv"))) {
  @l = csv($i);
  debug("L",@l);
}
