#!/bin/perl

# parses the text files in this directory into meta-mediawiki.pl format

require "/usr/local/lib/bclib.pl";
chdir("$bclib{githome}/PEANUTS");

for $i (glob "peanuts-???-????.txt") {

  # read file
  $all = read_file($i);

  my(@colons) = split(/^([A-Z][a-z]{1,10}:)/m, $all);

  for $j (@colons) {
    debug("J: $j");
  }

  next;

  # split by date
  for $j (split(/date:/i, $all)) {

    # first line is the date itself
    $j=~s/^(.*?)\n//;
    my($date) = $1;
    debug("J: $j");
  }
}


