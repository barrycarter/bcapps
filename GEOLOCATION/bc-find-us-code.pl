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

# TODO: combine search terms in such a way that I still know what term
# matched what line

# TODO: easier to just load big-us-cities.txt manually?

for $i (sort keys %findme) {
  # split back into city/state (pointless to code/uncode?)
  ($city,$state) = split(/:/,$i);

  # convert foo to f.*o.*o.* (the first letter must still be first)
  $city=~s/(.)/$1\.\*/isg;
  # state must be exact postal match (uppercase)
  $state=uc($state);

  # search term is
  $term="$city,$state";

  # can pretty much cache forever here (need only first match)
  ($out,$err,$res) = cache_command("egrep -im 1 '$term' big-us-cities.txt", "age=864000");
  chomp($out);
  print "$i $out\n";
}
