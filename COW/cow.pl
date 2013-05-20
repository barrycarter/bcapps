#!/bin/perl

# read list of cities, biggest first
require "/usr/local/lib/bclib.pl";
use Text::Unidecode;

chdir("/home/barrycarter/BCGIT/COW/");
open(A,"bzcat bigcit.txt.bz2|");

# note that starting at 0E,0N is not an issue
while (<A>) {
  /^(\d+) ([\d\.\-]+) ([\d\.\-]+) (.*?)$/||warn("BAD LINE: $_");
  ($pop, $lat, $lon, $name) = ($1,$2,$3,$4);

  # population = 0? ignore (and, since sorted, ignore rest too)
  if ($pop==0) {last;}

  $name = unidecode($name);

  # checks for repeats of the "London error"
  # TODO: check this better for other cities via proximity
  if ($seen{$pop}) {warn("POPULATION: $pop seen before ($name vs $seen{$pop})");}
  $seen{$pop} = $name;

  # count population so far (excluding current city) and compare to new city
  $ratio = $pop/($pop+$oldpop);
  $oldpop += $pop;

  # find "mid" point (not using xyz for now)
  ($newlat, $newlon, $newx, $newy, $newz) =
    gcstats($newlat, $newlon, $lat, $lon, $ratio);

#  debug("$pop/$name ($newlat,$newlon)");
}

print "$newlat $newlon\n";
print "$newx $newy $newz\n";

# results:
# 48.1427865119067 43.6927383256267
# 0.482477442393203 0.460948481355447 0.744810052899443
