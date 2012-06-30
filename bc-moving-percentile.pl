#!/bin/perl -l

# Given a series of data, find the "moving percentile" of the first element
require "/usr/local/lib/bclib.pl";

$val = <>;

while (<>) {
  if ($_>$val) {$more++;} elsif ($_<$val) {$less++;} else {$same++;}
  $num = $less+$same/2;
  $den = $less+$same+$more;
  debug("$num/$den");
#  debug("LESS/SAME/MORE: $less/$same/$more, SUM:",$less+$same+$more);
  print $num/$den;
}

