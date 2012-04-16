#!/bin/perl

# Given a code like akrn.oh, uses big-us-cities.txt to find "best
# candidate" for city

push(@INC,"/usr/local/lib");
require "bclib.pl";

# write my results
open(A,">/home/barrycarter/BCGIT/GEOLOCATION/codes-by-big-cities.txt");

@codes = split(/\n/, read_file("/home/barrycarter/BCGIT/GEOLOCATION/codelist.txt"));

# for $i (@codes) {
  # if xx.something, assume xx is state
#  if ($i=~/^(..)\.(.*)$/) {
#    ($city,$state) = ($2, $1);
#  }

#  $findme{"$city:$state"} = 1;
# }

# TODO: combine search terms in such a way that I still know what term
# matched what line

# TODO: easier to just load big-us-cities.txt manually?

for $i (@codes) {
  # form ar.lookoutrd for example
  if ($i=~/^(..)\.(.*)$/) {
    ($city, $state) = ($2,$1);
  } elsif ($i=~/^(.*?)\.(..)$/) {
    # athn.oh for example
    ($city, $state) = ($1,$2);
  } else {
#    warn("CODE IS NOT CITY/STATE: $i?");
    print A "$i NULL\n";
    next;
  }

  # convert foo to f.*o.*o.* (the first letter must still be first)
  $city=~s/(.)/$1\.\*/isg;

  # search term is
  $term="^$city,$state";

  # can pretty much cache forever here (need only first match, and
  # cities by area only if first one fails)
  # head -1 hits one match even if BOTH files have this city

  ($out,$err,$res) = cache_command("egrep -him 1 '$term' big-us-cities.txt big-area-cities.txt | head -1", "age=864000");
  chomp($out);
  unless ($out) {$out="-";}
  print A "$i $out\n";
}

close(A);
