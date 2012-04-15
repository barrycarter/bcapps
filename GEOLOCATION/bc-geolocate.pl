#!/bin/perl

# test geolocation

push(@INC, "/usr/local/lib");
require "bclib.pl";

# load regexps
for $i (split("\n", read_file("/home/barrycarter/BCGIT/GEOLOCATION/regexps.txt"))) {
  # ignore blanks and comments
  if ($i=~/^\s*$/ || $i=~/\#/) {next;}
  chomp($i);
  push(@regexp, $i);
}

open(A,"fgrep com.rr. /home/barrycarter/BCGIT/GEOLOCATION/sortedhosts.txt|");

while (<A>) {
  chomp;

# if (/^com\.rr\.biz\.(.*?)\.rrcs\-/) {debug("$_ matches");}

#  warn "TESTING";
#  next;

  # check vs regexps
  for $i (@regexp) {
    debug("I: $i");
#    debug("TESTING $_ vs $i");
    if ($_=~m$i) {
      debug("MATCH!: $1");
      last;
    }
  }

  debug("MATCH?: $1");

  debug("LINE: $_");
}

