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


for $i (split(/\n/,$hosts)) {
  # IP address? leave as is
  if ($i=~/^[\d\.]+$/) {
    print A "$i\n";
    next;
  }

  debug("I: $i");
  print A join(".",reverse(split(/\./,$i))),"\n";
}

close(A);

# now to sort (-n doesn't hurt alphas, but helps IP addresses)
system("sort -fn sortedhosts.txt -o sortedhosts.txt");


