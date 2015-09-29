#!/bin/perl

# Trivial script: compute the numerical differences between successive
# lines of stdin

require "/usr/local/lib/bclib.pl";

my($first,$cur);

while (<>) {

  unless ($first) {$first=1; $cur=$_; next;}

  print $_-$cur,"\n";
  $cur = $_;
}
