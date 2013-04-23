#!/bin/perl

# puts the hourly station averages into an SQLite3 db

require "/usr/local/lib/bclib.pl";

# look at the ish-history.csv file to map stations to data files
@all = split(/\n/, read_file("/home/barrycarter/BCGIT/db/ish-history.csv"));

for $i (@all) {
  # split into fields
  my(@fields) = split(/\,/,$i);

  # the station code field
  my($code) = $fields[6];
  $code=~s/\"//isg;

  # if no code, ignore
  unless ($code) {next;}

  # the file where data for this code is kept
  my($file) = ($fields[0]);

  debug("$code/$file");
#
  debug("I: $i");
}
