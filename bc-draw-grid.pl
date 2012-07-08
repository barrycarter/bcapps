#!/bin/perl

# draws a latitude/longtiude grid that's modified in some way (part of
# larger attempt to create mercator maps w/ arbitrary 'north pole' and
# otherwise 'zoomed' maps); future idea is to use slippy tiles (OSM)
# and not try to recreate everything myself

require "/usr/local/lib/bclib.pl";
open(A,">/tmp/bcdg.fly");

print A << "MARK";
new
size 800,600
setpixel 0,0,0,0,0
MARK
;

for $i (-9..9) {
  for $j (-18..18) {
    $lat = $i*10;
    $lon = $j*10;
    ($x,$y) = img_idtest($lat, $lon);
    print A "string 255,255,255,$x,$y,tiny,$lat,$lon\n";
  }
}

close(A);

# equiangular
sub img_idtest {
  my($lat,$lon) = @_;

  # using 800x600 hardcoded here = bad?
  my($y) = (90-$lat)*600/180;
  my($x) = ($lon+180)*800/360;

  return round($x),round($y);
}
