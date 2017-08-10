#!/bin/perl

# Converts output of HORIZONS CSV (eg, earth-on-eclipse-day.csv.bz2) to
# Mathematica usable format (fairly trivial)

# --fields: which fields desired (ie: 1,2,3,4)

require "/usr/local/lib/bclib.pl";

my(@fields) = split(/\,/, $globopts{fields});

# skip to start of data
while (<> !~/\$\$SOE/) {next;}

while (<>) {

  chomp;
  my(@f) = split(/\,\s*/, $_);

  my(@data);

  for $i (@fields) {
    $f[$i]=~s/E/*10^/;
    push(@data, "Rationalize\[$f[$i]\]");
  }

  print "{",join(", ",@data),"},\n";

}

