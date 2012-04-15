#!/bin/perl

# test geolocation

push(@INC, "/usr/local/lib");
require "bclib.pl";

# load regexps
for $i (split("\n", read_file("/home/barrycarter/BCGIT/GEOLOCATION/regexps.txt"))) {
  # ignore blanks and comments
  if ($i=~/^\s*$/ || $i=~/\#/) {next;}

  push(@regexp, $i);
}


debug(@regexp);
die "TESTING";

open(A,"fgrep com.rr. /home/barrycarter/BCGIT/GEOLOCATION/sortedhosts.txt|");

while (<A>) {
  chomp;
  debug("LINE: $_");
}

