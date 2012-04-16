#!/bin/perl

# Given a code like akrn.oh, uses big-us-cities.txt to find "best
# candidate" for city

push(@INC,"/usr/local/lib");
require "bclib.pl";

@codes = split(/\n/, read_file("/home/barrycarter/BCGIT/GEOLOCATION/codelist.txt"));

for $i (@codes) {
  # if xx.something, assume xx is state
  if ($i=~/^(..)\.(.*)$/) {
    ($city,$state) = ($2, $1);
  }

  $findme{"$city:$state"} = 1;
}

debug(sort keys %findme);

