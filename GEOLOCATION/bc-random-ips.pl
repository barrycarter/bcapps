#!/bin/perl

# Trivial script to generate a list of random IPs

push(@INC,"/usr/local/lib");
require "bclib.pl";

for $i (1..10) {
  @add=();
  for $j (1..4) {
    # TODO: exclude multicast + private?
    push(@add,int(rand()*256));
  }
  print join(".",@add),"\n";
}

