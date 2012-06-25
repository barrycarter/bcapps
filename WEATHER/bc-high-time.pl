#!/bin/perl

# for weather station KNMALBU80, determine time of high temperature
# (semi-insane method)

require "/usr/local/lib/bclib.pl";

# sort by decreasing temperature
open(A,"bzcat KNMALBUQ80.txt.bz2 | sort -t, -k2nr|");

while (<A>) {
  /^(.*?) (.*?),/;
  ($date,$time) = ($1, $2);

  # min temperature overwrites old one
  $min{$date} = $time;

  # unless we've seen a high temperature for this day already, note it
  if ($max{$date}) {next;}
  $max{$date} = $time;

}

for $i (sort keys %max) {
  print "$i $min{$i} $max{$i}\n";
}



