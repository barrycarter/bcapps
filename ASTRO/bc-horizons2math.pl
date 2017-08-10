#!/bin/perl

# Converts output of HORIZONS (eg, earth-on-eclipse-day.html.bz2) to
# Mathematica usable format

# see bc-osculating.pl for comments

require "/usr/local/lib/bclib.pl";

# TODO: this is really ugly and not useful in general
# TODO: allow templating and stuff, hard coding for eclipse only
@fields = ("JD", "X", "Y", "Z");

# skip to start of data
while (<> !~/\$\$SOE/) {next;}

# to store below
my($data, $eof);

# forever loop (but we do break out of it eventually)
for (;;) {

  my(%hash) = ();

  # TODO: the number of lines varies, need to do this much better
  # read 4 lines at a time
  for $i (1..4) {
    $data = <>;
    chomp($data);
    debug("DATA: $data");

    # end of data
    if ($data=~/\$\$EOE/) {$eof=1; last;}

    # TODO: ugly, first line will be JD
    if ($i==1) {
      $data=~s/^\s*(.*?)\s*\=//;
      $hash{JD} = $1;
      next;
    }

    while ($data=~s/^\s*([A-Z]+)\s*\=\s*([0-9E\+\-\.]+)//) {$hash{$1}=$2;}
  }

  # TODO: this is ugly, can I break out nested loops w/o GOTO?
  if ($eof) {last;}

  debug("HASH",%hash);
  my(@data) = ();

  for $i (@fields) {
    $hash{$i}=~s/E/*10^/;
    push(@data, "Rationalize[$hash{$i},0]");
  }

  debug("DATA","<start>",@data,"</start>");

  print "{",join(", ",@data),"}, \n";
}
