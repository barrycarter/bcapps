#!/bin/perl

# draws a latitude/longtiude grid that's modified in some way (part of
# larger attempt to create mercator maps w/ arbitrary 'north pole' and
# otherwise 'zoomed' maps); future idea is to use slippy tiles (OSM)
# and not try to recreate everything myself

require "/usr/local/lib/bclib.pl";

# grab all level 4? OSM maps (this isn't as hideous as it looks thanks
# to caching)
sub grab_osm_maps {
  for $lat (-82..82) {
    for $lon (-180..180) {
      debug(osm_map($lat,$lon,4));
    }
  }
}

($png, $x, $y) = osm_map(35,-106,4);
debug("$png/$x/$y");
debug(slippy2latlon(3,6,4,74,86.5));

die "TESTING";

open(A,">/tmp/bcdg.fly");

# spacing in degrees
$latspace = 15;
$lonspace = 20;

# the function
$f = \&img_idtest;

print A << "MARK";
new
size 800,600
setpixel 0,0,255,255,255
MARK
;

for ($lat=90; $lat>=-90; $lat-=$latspace) {
  for ($lon=180; $lon>=-180; $lon-=$lonspace) {
    ($x,$y) = &$f($lat, $lon);

    # position string a little "SE" of dot
    my($sx,$sy) = ($x+5, $y+5);
    print A "string 0,0,0,$sx,$sy,tiny,$lat,$lon\n";

    # line to next east longitude
    my($xe,$ye) = &$f($lat, $lon+20);
    print A "line $x,$y,$xe,$ye,255,0,0\n";

    # line to next south latitude
    my($xs,$ys) = &$f($lat-15, $lon);
    print A "line $x,$y,$xs,$ys,0,0,255\n";

    # fcircle must come last to avoid being overwritten by lines
    print A "circle $x,$y,5,0,0,0\n";

  }
}

close(A);

system("fly -i /tmp/bcdg.fly -o /tmp/bcdg.gif && xv /tmp/bcdg.gif&");

# equiangular
sub img_idtest {
  my($lat,$lon) = @_;

  # using 800x600 hardcoded here = bad?
  my($y) = (90-$lat)*600/180;
  my($x) = ($lon+180)*800/360;

  return round($x),round($y);
}
