#!/bin/perl

# Given the output of HORIZONS data for osculating elements, compute
# change in ecliptic longitude over given period of time with some
# assumptions

require "/usr/local/lib/bclib.pl";

# wait for $$SOE
while (<> !~/\$\$SOE/) {next;}

my($data,$lastlong);

# forever loop (but we do break out of it eventually)
for (;;) {

  my(%hash) = ();

  # read 5 lines at a time
  for $i (1..5) {
    $data = <>;
    while ($data=~s/^\s*([A-Z]+)\s*\=\s*([0-9E\+\-\.]+)//) {$hash{$1}=$2;}
  }

  # the ecliptic longitude is MA + OM + W
  my($long) = $hash{MA}+$hash{OM}+$hash{W};

  # special case if we are first
  unless ($lastlong) {$lastlong=$long; next;}

  # except for first case, print diff
  my($diff) =  fmodp($long-$lastlong,360);
  debug("DIFF: $diff");

  # store last seen longitude
  $lastlong = $long;

}



