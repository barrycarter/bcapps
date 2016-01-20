#!/bin/perl

require "/usr/local/lib/bclib.pl";

while (<>) {

  chomp;
  my(@data) = split(/\s+/, $_);
  map(s/[h\s]//g, @data);
  my($ck) = hex(pop(@data));
#  debug("DATA", @data);

  my(@test) = (32,16,8,2,4,1);

  # note that this is NOT hex(string) because two digit pairs (base
  # 256) are treated as a single number

  $sum = 0;
  for $i (0..$#test) {
    $sum += $test[$i]*$data[$i];
  }

  debug("SUM: $sum vs $ck");

}
