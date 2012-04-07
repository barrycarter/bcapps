#!/bin/perl

# given sortedhosts.txt, determine which TLD, 2LD, etc, appear most often

# eg, info.barrycarter.foo would add 1 hit to "info",
# "info.barrycarter", and "info.barrycarter.foo"

push(@INC,"/usr/local/lib");
require "bclib.pl";

$all = read_file("sortedhosts.txt");
unless ($all) {die "No sortedhosts.txt?";}

for $i (split(/\n/,$all)) {
  # lc
  $i = lc($i);

  # split into dots
  @pieces = split(/\./, $i);

  # and now generate all "TLD"s for this host
  for $j (0..$#pieces) {
    $host = join(".",@pieces[0..$j]);
    $count{$host}++;
  }
}

# sort
@hosts = sort {$count{$b} <=> $count{$a}} (keys %count);

open(B,">hostfreq.txt");

for $i (@hosts) {
  print B "$i: $count{$i}\n";
}



