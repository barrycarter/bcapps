#!/bin/perl

# determine center of population
# --points=n: stop after n points (for testing)

# read list of cities, biggest first
require "/usr/local/lib/bclib.pl";
use Text::Unidecode;

chdir("/home/barrycarter/BCGIT/COW/");
open(A,"bzcat bigcit.txt.bz2|");
open(B,">/var/tmp/temp.kml");

print B << "MARK";
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
MARK
;

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
  ($newlat, $newlon, $newx, $newy, $newz, $ang, $dist) =
    gcstats($newlat, $newlon, $lat, $lon, $ratio);

  $n++;
  if ($n>$globopts{points}) {last;}

  print B "<Placemark><Point><coordinates>$newlon,$newlat</coordinates></Point>\n";
  print B "<name>Point $n</name>\n<description>\n";
  print B sprintf("Population seen: %d<br/>\n",$oldpop-$pop);
  print B sprintf("Population of $name: %d<br/>\n",$pop);
  print B sprintf("%age of population seen: %0.2f%%<br/>\n",$ratio*100);
  print B sprintf("Total distance from point %d to $name: %d miles<br/>\n", $n-1, $ang*$EARTH_RADIUS);
  print B sprintf("%0.2f%% of %d miles: %d miles<br/>\n", $ratio*100, $ang*$EARTH_RADIUS, $ang*$ratio*$EARTH_RADIUS);
  print B sprintf("Moved %d miles from point %d towards $name<br/>\n", $ang*$ratio*$EARTH_RADIUS, $n-1);
  print B"</description></Placemark>\n";

}

print "$newlat $newlon\n";
print "$newx $newy $newz\n";

print B "</Document></kml>\n";
close(B);

# results:
# 48.1427865119067 43.6927383256267
# 0.482477442393203 0.460948481355447 0.744810052899443

# TODO: check that population of country doesnt exceed its actual population
# TODO: same for world in general
