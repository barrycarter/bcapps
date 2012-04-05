#!/bin/perl

# Trivial script to generate a list of random IPs

push(@INC,"/usr/local/lib");
require "bclib.pl";

for $i (1..10000) {
  @add=();
  for $j (1..4) {
    # TODO: exclude multicast + private?
    push(@add,int(rand()*256));
  }
  $ip = join(".",@add);
  print "mtr -rwc 1 $ip >> /var/tmp/mtr-single-file-test.txt\n";
}

