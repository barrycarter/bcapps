#!/bin/perl

# test geolocation

push(@INC, "/usr/local/lib");
require "bclib.pl";

# load regexps
for $i (split("\n", read_file("/home/barrycarter/BCGIT/GEOLOCATION/regexps.txt"))) {
  # ignore blanks and comments
  if ($i=~/^\s*$/ || $i=~/\#/) {next;}
  chomp($i);

  # below is bad because it disallows post-/ options
  $i=~s/\///isg;

  push(@regexp, $i);
}

open(A,"fgrep com.rr. /home/barrycarter/BCGIT/GEOLOCATION/sortedhosts.txt|");

while (<A>) {
  chomp;

  # check vs regexps
  for $i (@regexp) {
    if (@parts=($_=~m/$i/)) {
      # join all matched expressions with "."
      # TODO: is above wise?
      $code = join(".",@parts);
      $match = $i;
      $iscode{$code} = 1;
      last;
    }
  }

  print "$_ -> $code ($match)\n";
}

# print all found codes
debug(sort keys %iscode);



