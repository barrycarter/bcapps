#!/bin/perl

# puts the hourly station averages into an SQLite3 db

require "/usr/local/lib/bclib.pl";

# the list of "meaningful" codes
for $i (split(/\n/,read_file("/home/barrycarter/BCGIT/WEATHER/nsd_cccc_annotated.txt"))) {
  $i=~s/\;.*//isg;
  $iscode{$i} = 1;
}

# look at the ish-history.csv file to map stations to data files
@all = split(/\n/, read_file("/home/barrycarter/BCGIT/WEATHER/ish-history.csv"));

for $i (@all) {
  # split into fields
  my(@fields) = split(/\,/,$i);

  # the station code field
  my($code) = $fields[6];
  $code=~s/\"//isg;

  # if not a valid code, ignore
  unless ($iscode{$code}) {next;}

  # the file where data for this code is kept
  my($file) = "/mnt/sshfs/WEATHER/CALC/$fields[0]-$fields[1].res";
  $file=~s/\"//isg;

  # does it exist
  unless (-f $file) {
    warn "NO SUCH FILE: $file ($code)";
  }

#  debug("$code/$file");
#
#  debug("I: $i");
}
