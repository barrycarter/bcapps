#!/bin/perl

# shows where sun is shining, twilight, etc

# TODO: first and third line below are ugly!
push(@INC, "/usr/local/lib");
require "bclib.pl";
chdir("/usr/local/etc/sun");

# from wolframalpha (in m)
# (yes, I know I define a similar constant in bclib.pl)
$EARTH_CIRC = 4.007504e+7;

$now = time();
$outputfile = "/home/barrycarter/BCINFO/sites/TEST/sunstuff.html";

# TODO: ugly ugly ugly (should use Perl funcs and also not do "cat >>"
$ENV{TZ} = "GMT";
system("echo Last updated: `date` > $outputfile");
system("/bin/cat gbefore.txt >> $outputfile");

open(A, ">>$outputfile");

# directly from mathematica 

sub decl {
  my($x) = @_;

  # convert to seconds from latest spring equinox
  $x -= 1.3006632937893438*10**9;

    return (
0.37808401703940736 +
0.3810373468678206*cos(0.3074066821871051 - 3.9821243192021897e-7*$x) +
23.260776335116*cos(1.6031468236573432 - 1.9910621596010949e-7*$x) +
0.17118769496986821*cos(1.4545723908701285 + 5.973186478803284e-7*$x) +
0.008146125242501636*cos(2.756482750676952 + 7.964248638404379e-7*$x)
);
}

sub ra {
  my($x) = @_;

  # convert to seconds since latest spring equinox
  $x -= 1.3006632548642015*10**9;

  my($temp) = (
-0.12362547330377642 + 0.003653051241507621*cos(1.7184400853442734 -
7.964247794495168e-7*$x) + 0.1226898815038194*cos(0.2853850527151302 -
1.991061948623792e-7*$x) + 0.16534691830933743*cos(1.502453306625312 +
3.982123897247584e-7*$x) + 0.005290041878837918*cos(2.7898112178483023 +
5.973185845871376e-7*$x)
);

  # need to undo what racorrected2 does
  return 24*$x/3.1556955380130082e+7 + $temp;

}

($dec,$ra) = (decl($now), ra($now));

debug("$dec/$ra");

# sidereal time in Greenwich
$sdm = mod(($now%86400)/3600+12+24*($now - 1.3006632548642015e+9)/3.1556955380130082e+7,24);

# difference to $ra (east of Greenwich)
$dege = ($ra-$sdm)*15;

# determine solar declination

($lat, $lon) = ($dec, $dege);

# finding antipode here is ugly
$alat = -1*$lat;
$alon = (180+$dege);

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

system("echo Last updated `date` known broken >> $outputfile");
