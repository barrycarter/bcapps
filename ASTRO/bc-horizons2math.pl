#!/bin/perl

# Converts output of HORIZONS CSV (eg, earth-on-eclipse-day.csv.bz2) to
# Mathematica usable format (fairly trivial)

# --label: what to name the variable
# --fields: which fields desired (ie: 1,2,3,4)

require "/usr/local/lib/bclib.pl";

my(@fields) = split(/\,/, $globopts{fields});

# the variable

print "$globopts{label} = {\n";

# skip to start of data
while (<> !~/\$\$SOE/) {next;}

while (<>) {

  chomp;

  if (/\$\$EOE/) {last;}

  my(@f) = split(/\,\s*/, $_);

  my(@data);

  for $i (@fields) {
    $f[$i]=~s/E/*10^/;
    push(@data, "Rationalize[$f[$i],0]");
  }

  print "{",join(", ",@data),"},\n";

}

# end list and remove null

print "};\n";

print "$globopts{label} = Drop[$globopts{label}, -1];\n";
