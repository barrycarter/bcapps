#!/bin/perl

# shows where sun is shining, twilight, etc

require "bclib.pl";

# from wolframalpha (in m)
# (yes, I know I define a similar constant in bclib.pl)
$EARTH_CIRC = 4.007504e+7;

$outputfile = "/home/barrycarter/BCINFO/sites/TEST/sunstuff.html";
system("cp -f gbefore.txt $outputfile");
open(A, ">>$outputfile");

# pretending sun is overhead at ABQ, impossible in real life
print A << "MARK"

x = new google.maps.LatLng(35,-106.5);

MARK
;

# TODO: marker for Sun
# TODO: add moon

for $i (1..15) {
  debug("EC: $EARTH_CIRC");

  # 6 degrees at a time
  $r = $EARTH_CIRC/30*$i;
  debug("R: $r");

  # figure out color (always red + some cyan for first 15, so white at top)
  $lev = 255*(1-$i/15);
  hsv2rgb(1,$lev,$lev);

  debug("R: $r");
  print A << "MARK";

new google.maps.Circle({
 center: x,
 radius: $r,
 map: map,
 strokeWeight: 1,
 fillOpacity: 0.1,
 fillColor: "#FF0000"
});

MARK
;
}


close(A);

system("cat gend.txt >> $outputfile");
