#!/bin/perl

# determine center of population
# --points=n: stop after n points (for testing)

# read list of cities, biggest first
require "/usr/local/lib/bclib.pl";
use Text::Unidecode;

die "This program is not used; if placed back into production, replace gbefore.txt below to include API key";

chdir("/home/barrycarter/BCGIT/COW/");
open(A,"bzcat bigcit.txt.bz2|");
open(B,">/var/tmp/temp.html");
print B read_file("../gbefore.txt");

# TODO: ugly for drawing otherwise OK
($newlat,$newlon)=(0,0);

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

  # useful to remember old point
  ($oldnewlat, $oldnewlon) = ($newlat, $newlon);

  # find "mid" point (not using xyz for now)
  ($newlat, $newlon, $newx, $newy, $newz, $ang, $dist) =
    gcstats($newlat, $newlon, $lat, $lon, $ratio);

  $n++;
  if ($n>$globopts{points}) {last;}

  @info=();
  push(@info,sprintf("Population seen: %d",$oldpop-$pop));
  push(@info,sprintf("Population of $name: %d",$pop));
  push(@info,sprintf("%age of population seen: %0.2f%%",$ratio*100));
  push(@info,sprintf("Total distance from point %d to $name: %d miles", $n-1, $ang*$EARTH_RADIUS));
  push(@info,sprintf("%0.2f%% of %d miles: %d miles", $ratio*100, $ang*$EARTH_RADIUS, $ang*$ratio*$EARTH_RADIUS));
  push(@info,sprintf("Moved %d miles from point %d towards $name", $ang*$ratio*$EARTH_RADIUS, $n-1));
  $info = join(" ",@info);
  # using Google Maps JS API (not KML) just to get great circles
  $placemark = << "MARK";

new google.maps.Marker({
 position: new google.maps.LatLng($newlat,$newlon),
 map: map,
 flat: true,
 title:"Point $n: $info",
});

// new google.maps.Marker({
// position: new google.maps.LatLng($lat,$lon),
// map: map,
// flat: true,
// title:"$name"
// });

new google.maps.Polyline({
 geodesic: true,
 path: [new google.maps.LatLng($oldnewlat, $oldnewlon),
        new google.maps.LatLng($newlat, $newlon)],
 strokeColor: "#000000",
 strokeWeight: 0.5,
 icons: [{icon: google.maps.SymbolPath.FORWARD_CLOSED_ARROW}],
 map: map
});

new google.maps.Polyline({
 geodesic: true,
 path: [new google.maps.LatLng($newlat, $newlon),
        new google.maps.LatLng($lat, $lon)],
 strokeColor: "#ff0000",
 strokeWeight: 0.25,
 map: map
});

new google.maps.Polyline({
 geodesic: true,
 path: [new google.maps.LatLng($oldnewlat, $oldnewlon),
        new google.maps.LatLng($lat, $lon)],
 strokeColor: "#0000ff",
 strokeWeight: 2,
 map: map
});

MARK
;

  print B $placemark;


}


print "$newlat $newlon\n";
print "$newx $newy $newz\n";

print B read_file("../gend.txt");

# results:
# 48.1427865119067 43.6927383256267
# 0.482477442393203 0.460948481355447 0.744810052899443

# TODO: check that population of country doesnt exceed its actual population
# TODO: same for world in general
