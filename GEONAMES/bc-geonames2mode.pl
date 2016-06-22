#!/bin/perl

# converts geonames to one or more tables for modeanalytics.com

# NOTE: 500MB limit = split, but maybe can use "split" command for that

require "/usr/local/lib/bclib.pl";

open(A,"allCountries.txt");

while (<A>) {

  my(@fields) = split("\t", $_);

  # TODO: check no fields I use have commas
  print join("\t", @fields[0,2,4,5,7,8,10,11,12,13,14,15,17]),"\n";

}


