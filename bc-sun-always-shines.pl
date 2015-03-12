#!/bin/perl

# shows where sun is shining, twilight, etc

require "/usr/local/lib/bclib.pl";

# from wolframalpha (in m)
# (yes, I know I define a similar constant in bclib.pl)
$EARTH_CIRC = 4.007504e+7;

$now = time();
$outputfile = "/sites/TEST/sunstuff.html";

# TODO: ugly ugly ugly (should use Perl funcs and also not do "cat >>"
$ENV{TZ} = "GMT";
system("echo '<meta http-equiv=\"refresh\" content=\"60\">' > $outputfile");
system("echo Last updated: `date` >> $outputfile");
system("/bin/cat /usr/local/etc/gbefore.txt >> $outputfile");

open(A, ">>$outputfile");

my(%data) = sunmooninfo(0,0);

debug("DATA",unfold(\%data));

my(%data) = sunmooninfo(-79-83,-3.6);

debug("DATA2",unfold(\%data));

die "TESTING";

# ($ra, $dec) = position("sun", $now);

# sidereal time in Greenwich
$sdm = gmst($now);

# difference to $ra (east of Greenwich)
$dege = ($ra-$sdm)*15;

# determine overhead point
($lat, $lon) = ($dec, $dege);

# finding antipode here is ugly
$alat = -1*$lat;
$alon = (180+$dege);

print A << "MARK"

pt = new google.maps.LatLng($lat,$lon);
ap = new google.maps.LatLng($alat,$alon);

new google.maps.Marker({
 position: pt,
 map: map,
 Icon: "http://test.barrycarter.info/sun.png",
 title:"Sun"
});

new google.maps.Marker({
 position: ap,
 map: map,
 Icon: "http://test.barrycarter.info/nemesis.png",
 title:"Nemesis"
});

MARK
;

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

# for moon, only one circle, so do it here
($mra, $mdec) = position("moon", $now);
$mdege = ($mra-$sdm)*15;
($mlat, $mlon) = ($mdec, $mdege);
$mrad = $EARTH_CIRC/4;

print A << "MARK"

mpt = new google.maps.LatLng($mlat,$mlon);

new google.maps.Circle({
 center: mpt,
 radius: $mrad,
 map: map,
 strokeWeight: 2,
 strokeColor: "#ffffff",
 fillOpacity: 0,
 fillColor: "#ffffff"
});

new google.maps.Marker({
 position: mpt,
 map: map,
 Icon: "http://test.barrycarter.info/moon.png",
 title:"Moon"
});

MARK
;

close(A);

system("cat /usr/local/etc/sun/gend.txt >> $outputfile");
