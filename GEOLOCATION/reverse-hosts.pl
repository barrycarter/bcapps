#!/bin/perl

# Given samplehosts.txt, create a file that "reverses" the host name
# so the most signifigant part comes first (IP addresses left as is)
# and case-insensitive sort result

push(@INC,"/usr/local/lib");
require "bclib.pl";

# TODO: read samplehosts[1-3] as well, but samplehosts4.txt is the biggie!
$hosts = read_file("samplehosts4.txt");
unless ($hosts) {die "samplehosts.txt empty or wrong dir!";}
open(A,">sortedhosts.txt");
open(B,">sortedips.txt");


for $i (split(/\n/,$hosts)) {
  # remove count (from uniq -c)
  $i=~s/^\s*\d+\s*//;
  
  debug("I: $i");

  # IP address? leave as is
  if ($i=~/^[\d\.]+$/) {
    print B "$i\n";
    next;
  }

  print A join(".",reverse(split(/\./,$i))),"\n";
}

close(A);

# now to sort
system("sort -f sortedhosts.txt -o sortedhosts.txt");
# below is an imperfect sorting 1.8 > 1.79
system("sort -fn sortedips.txt -o sortedips.txt");


