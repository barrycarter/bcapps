#!/bin/perl

# converts geonames to one or more tables for modeanalytics.com

# NOTE: must prepend headers.txt to output of this program;
# modeanalytics.com ignores blanks in header row

# NOTE: 500MB limit = split, but maybe can use "split" command for that

# about 11 million rows

require "/usr/local/lib/bclib.pl";

# randomly sorted
open(A,"allCountries.txt.rand");

while (<A>) {

  my(@fields) = split("\t", $_);

  # some rows have quotes, so I must do this
  for $i (@fields) {
    $i=~s/\"//g;
    $i=qq%"$i"%;
  }

  # TODO: ok to quote numerical fields? (yes, it appears to be)
#  map($_=qq%"$_"%, @fields);

  # TODO: check no fields I use have commas
  print join(",", @fields[0,2,4,5,7,8,10,11,12,13,14,15,17]),"\n";

#  if (++$count> 20000) {exit;}

}


