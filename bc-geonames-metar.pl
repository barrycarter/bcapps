#!/bin/perl

# Confirms all METAR stations are in geonames (will add if not)

require "/usr/local/lib/bclib.pl";

$metar = read_file("/home/barrycarter/BCGIT/db/nsd_cccc_annotated.txt");

# pick these off 20 at a time
open(A,"|parallel -j 20");

# below was during testing
# open(A,">/tmp/ignore.txt");


for $i (split(/\n/, $metar)) {
  $i=~s/\;.*//isg;
  print A "curl -o /var/tmp/geonames/$i.metar 'http://api.geonames.org/search?name_equals=$i&username=barrycarter'\n";
  debug("I: $i");
}

close(A);

