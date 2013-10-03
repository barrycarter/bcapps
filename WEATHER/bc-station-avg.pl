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
  # split into fields get rid of quotes
  my(@fields) = split(/\,/,$i);
  map(s/\"//g, @fields);

  # the station code field
  my($code) = $fields[6];

  # if not a valid code, ignore
  unless ($iscode{$code}) {next;}

  # how much data in years (approx)
#  my($range) = ($fields[11]-$fields[10])/10000;
#  if ($range < 10) {next;}

  # the file where data for this code is kept
  my($file) = "/mnt/sshfs/WEATHER/CALC/$fields[0]-$fields[1].res";
  debug("FILE: $file");

  # this is hideously ugly way to check we have at least 10 years data/date
  my($miny) = `cut -d" " -f 4 $file | sort -n | head -1`;
  debug("MIN: $code: $miny");
  if ($miny < 10) {next;}

  # TODO: check that we don't have missing rows entirely

  # does it exist
  unless (-f $file) {
    warn "NO SUCH FILE: $file ($code)";
    next;
  }

  # read file add code write to stdout
  for $j (split(/\n/, read_file($file))) {
    print "$code $j\n";
  }

  debug("$code/$file");
#
#  debug("I: $i");
}
