#!/bin/perl

# draws a latitude/longtiude grid that's modified in some way (part of
# larger attempt to create mercator maps w/ arbitrary 'north pole' and
# otherwise 'zoomed' maps); future idea is to use slippy tiles (OSM)
# and not try to recreate everything myself

require "/usr/local/lib/bclib.pl";

# spacing in degrees
$latspace = 15;
$lonspace = 20;

# the function
$f = \&img_idtest;

warn "TESTING w single value of x y";

# loop through all level 4 slippy tiles
for $x (0..15) {
  for $y (0..15) {
#    unless ($x==3 && $y==6) {next;}

    # reset border and distortion parameters
    %border = ();
    @params = ();

    # below is sheer laziness, could've written out 4 statements
    for $px (0,255) {
      for $py (0,255) {
	# the borders of this slippy tile
	($lat,$lon) = slippy2latlon($x,$y,4,$px,$py);
	# how we would map this border
	($myx, $myy) = &$f($lat,$lon);
	# store this info
#	$translate{$px}{$py}{x} = $myx;
#	$translate{$px}{$py}{y} = $myy;
	# the distortion parameter for convert (imagemagick)
	push(@params, "$px,$py,$myx,$myy");

      }
    }

    # build up the convert command
    $distort = join(" ",@params);
    $distort = "'$distort'";

    # and convert..
    system("convert /var/cache/OSM/4,$x,$y.png -virtual-pixel transparent -distort Perspective $distort /tmp/bcdg-$x-$y.png");
  }
}

die "TESTING";

open(A,">/tmp/bcdg.fly");

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

# grab all level 4? OSM maps (this isn't as hideous as it looks thanks
# to caching) [only needed to do this once]
sub grab_osm_maps {
  for $lat (-82..82) {
    for $lon (-180..180) {
      debug(osm_map($lat,$lon,4));
    }
  }
}

