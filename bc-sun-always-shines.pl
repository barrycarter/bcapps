#!/bin/perl

# shows where sun is shining, twilight, etc

require "bclib.pl";

# from wolframalpha (in m)
# (yes, I know I define a similar constant in bclib.pl)
$EARTH_CIRC = 4.007504e+7;

$outputfile = "/home/barrycarter/BCINFO/sites/TEST/sunstuff.html";
system("cp -f gbefore.txt $outputfile");
open(A, ">>$outputfile");

# determine solar declination
$now = time();

# approximations courtesy Mathematica (not sure why constant term is non-0)
# time since vernal equinox 2011; accurate w/in .005 degree until 2021
$x = $now - 1.3006416937893343e+9;
$dec = 0.37845200201734086 +
 0.38116909443611807*cos(0.30502424424664315 - 3.982131644462728e-7*$x) +
 23.26157394172938*cos(1.6032489688783176 - 1.991065822231364e-7*$x) +
 0.17123511177389686*cos(1.4545340752802227 + 5.973197466694092e-7*$x) +
 0.008152035794419562*cos(2.760234392686175 + 7.964263288925456e-7*$x);

# the RA vernal equinox is slightly different (why?!)
# ra accurate w/in .15 degree until 2021

$y = $now - 1.3006416548643436e+9;
$ra = -0.12401429788269641 +
      0.12272033119588897*cos(0.2827810951693645 - 1.9910654343479365e-7*$x) +
      0.16538008039487773*cos(1.502315236751995 + 3.982130868695873e-7*$x) +
      24*mod(3.168879058958857e-8*$x, 1);

debug("RADEC: $ra, $dec");

die "TESTING";

($lat, $lon) = (35, -106.5);

# finding antipode here is ugly
$alat = -1*35;
$alon = (180-106.5);

# pretending sun is overhead at ABQ, impossible in real life
print A << "MARK"

pt = new google.maps.LatLng($lat,$lon);
ap = new google.maps.LatLng($alat,$alon);

MARK
;

# TODO: marker for Sun
# TODO: add moon

for $i (1..15) {

  # 6 degrees at a time (biggest one first)
  $r1 = $EARTH_CIRC/2/30*(16-$i);
  $r2 = $EARTH_CIRC/2/30*(16-$i);

  # if i==15, that's the biggest light circle
  if ($i == 1) {
    ($sw1, $opc1) = (2, 0.2);
  } else {
    ($sw1, $opc1) = (0.1, 0.01);
  }

  # and also biggest dark circle
  if ($i == 1) {
    $opc2 = 0.2;
  } else {
    $opc2 = 0;
  }

  # civil/nautical/astro twiling
  if ($i <= 4 ) {$sw2 = 1;} else {$sw2 = 0.1;}

  # figure out color (always red + some cyan for first 15, so white at top)
  $lev = 255*($i/15);
  $col = sprintf("#%0.2x%0.2x%0.2x",255,255,255);

  debug("LEV: $lev, COL: $col");

  print A << "MARK";

new google.maps.Circle({
 center: pt,
 radius: $r1,
 map: map,
 strokeWeight: $sw1,
 fillOpacity: $opc1,
 fillColor: "#ffffff"
});

new google.maps.Circle({
 center: ap,
 radius: $r2,
 map: map,
 strokeWeight: $sw2,
 fillOpacity: $opc2,
 fillColor: "#000000"
});

MARK
;
}


close(A);

system("cat gend.txt >> $outputfile");
