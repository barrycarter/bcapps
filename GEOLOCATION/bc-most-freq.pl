#!/bin/perl

# determine which TLD, 2LD, etc, appear most often in hosts that do
# not match any patterns in regexp.txt

# eg, info.barrycarter.foo would add 1 hit to "info",
# "info.barrycarter", and "info.barrycarter.foo"

push(@INC,"/usr/local/lib");
require "bclib.pl";

$all = read_file("unresolvedhosts.txt");
unless ($all) {die "No unresolvedhosts.txt?";}

for $i (split(/\n/,$all)) {
  # lc
  $i = ".".lc($i);

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
  # ignore unique hosts (and since sorted, first appearance of 1 suffices)
  if ($count{$i}<2) {last;}
  print B "$i: $count{$i}\n";
}



