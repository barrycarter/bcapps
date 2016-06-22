#!/bin/perl

# converts geonames to one or more tables for modeanalytics.com

# NOTE: 500MB limit = split, but maybe can use "split" command for that

# about 11 million rows

require "/usr/local/lib/bclib.pl";

open(A,"allCountries.txt");

while (<A>) {

  my(@fields) = split("\t", $_);

  # TODO: ok to quote numerical fields?
  map($_=qq%"$_"%, @fields);

  # TODO: check no fields I use have commas
  print join(",", @fields[0,2,4,5,7,8,10,11,12,13,14,15,17]),"\n";

}


