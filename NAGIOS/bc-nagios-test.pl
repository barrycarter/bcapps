#!/bin/perl

# Runs a nagios test; if a plugin exists, use it; otherwise, use
# subroutines defined here

push(@INC,"/usr/local/lib");
require "bclib.pl";

open(A,">/tmp/bc-nagios-test.txt");
for $i (sort keys %ENV) {
  print A "$i -> $ENV{$i}\n";
}
close(A);

