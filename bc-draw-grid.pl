#!/bin/perl

# draws a latitude/longtiude grid that's modified in some way (part of
# larger attempt to create mercator maps w/ arbitrary 'north pole' and
# otherwise 'zoomed' maps); future idea is to use slippy tiles (OSM)
# and not try to recreate everything myself
# --gridonly: only draw the grid (useful for testing)
# --nogrid: don't draw the grid (useful for testing)

# TODO: adaptive zooming (zoom more where needed)

require "/usr/local/lib/bclib.pl";

# debug(latlonrot(0,100,100,"z"));

# spacing in degrees
$latspace = 15;
$lonspace = 20;

# x/y of image
$xsize = 800;
$ysize = 600;

# use slippy tiles at this zoom level (prev hardcoded at 4)
$zoomtile = 2;

# test of "pre" function
sub pre {
  my($lat,$lon) = @_;

  # TODO: add zooming somehow? (can't do it here though)

#  ($lat, $lon) = latlonrot($lat, $lon, +106, "z");
#  ($lat, $lon) = latlonrot($lat, $lon, -35, "y");
#  ($lat, $lon) = latlonrot($lat, $lon, 90, "x");

#  $lon= fmod($lon-+106.5,360);
  return $lat,$lon;
}

$proj = "ortho"; $div = 6378137/1.1; $pre = \&pre;
# $proj = "merc"; $div = 20000000; $pre = \&pre;
# <h>And here's to you...</h>
# $proj = "robin"; $div = 17005833; $pre = \&pre;

open(A,">/tmp/bdg2.fly")||die("Can't open /tmp/bdg2.fly, $!");

print A << "MARK";
new
size $xsize,$ysize
setpixel 0,0,255,255,255
MARK
;

# making this more efficient and flexible by only calcing values once
for ($lat=90; $lat>=-90; $lat-=$latspace) {
  # TODO: this is terrible way of skipping grid
  if ($globopts{nogrid}) {next;}
  for ($lon=180; $lon>=-180; $lon-=$lonspace) {
    # cheating by not using list
    $proj4{"$lat,$lon"} = join(",",proj4($lat, $lon, $proj, $div, $xsize, $ysize, $pre));
  }
}

# now to use the values we just calced
for ($lat=90; $lat>=-90; $lat-=$latspace) {
  # TODO: this is terrible way of skipping grid
  if ($globopts{nogrid}) {next;}
  for ($lon=180; $lon>=-180; $lon-=$lonspace) {
    my($x,$y) = split(/\,/,$proj4{"$lat,$lon"});
    debug("LATLON: $lat, $lon, XY: $x,$y");
    if ($x == -1) {next;}

    # position string a little "SE" of dot
    my($sx,$sy) = ($x+5, $y+5);
    print A "string 0,0,0,$sx,$sy,tiny,$lat,$lon\n";

    # same lat, east long
    $lone = $lon+$lonspace;
    if ($lone>180){$lone-=360;}
    my($xe,$ye) = split(/\,/, $proj4{"$lat,$lone"});
    debug("$xe/$ye, alf");
    unless ($xe == -1) {
    print A "line $x,$y,$xe,$ye,255,0,0\n";
  }

    # line to next south latitude
    $lats = $lat-$latspace;
    my($xs,$ys) = split(/\,/, $proj4{"$lats,$lon"});
    debug("$xs/$ys, bet");
    unless ($xs == -1 || $lats<-90) {
    print A "line $x,$y,$xs,$ys,0,0,255\n";
  }

    # fcircle must come last to avoid being overwritten by lines
    print A "circle $x,$y,5,0,0,0\n";

  }
}

close(A);

system("fly -q -i /tmp/bdg2.fly -o /tmp/bdg2.gif");

if ($globopts{gridonly}) {exit;}

# TODO: better temp file naming
open(A,">/tmp/bdg.fly")||die("Can't open /tmp/bdg.fly, $!");
print A << "MARK";
new
size $xsize,$ysize
MARK
;

# loop through all level $zoomtile slippy tiles
for $x (0..(2**$zoomtile-1)) {
  for $y (0..2**$zoomtile-1) {

    debug("XY: $x $y");

    if ($taint{$x}{$y}) {
      debug("SKIPPING $x/$y, TAINTED");
      next;
    }

    # TODO: better temp file naming (but do cache stuff like this)
    # TODO: consider caching more carefully in future

    # reset border and distortion parameters
    %border = ();
    @params = ();

    # below is sheer laziness, could've written out 4 statements
    for $px (0,255) {
      for $py (0,255) {
	# the borders of this slippy tile
	($lat,$lon) = slippy2latlon($x,$y,$zoomtile,$px,$py);
	debug("POINT $px,$py -> $lat,$lon");
	# how we would map this border
	($myx, $myy) = proj4($lat,$lon,$proj,$div,$xsize,$ysize,$pre);

	if ($myx==-1 || $myy==-1) {
	  # can't use 'last' here, too deeply nested
	  $taint{$x}{$y} = 1;
	  debug("$x $y TAINTED");
	  last;
	}

	# the distortion parameter for convert (imagemagick)
	push(@params, "$px,$py,$myx,$myy");

      }
    }

    # skip if tainted
    if ($taint{$x}{$y}) {next;}

    # build up the convert command
    $distort = join(" ",@params);
    $distort = "'$distort'";

    # and convert..
    $cmd = "convert -mattecolor transparent -extent ${xsize}x$ysize -background transparent -matte -virtual-pixel transparent -distort Perspective $distort /var/cache/OSM/$zoomtile,$x,$y.png /tmp/bcdg-$x-$y.gif";
    debug("CMD: $cmd");
    system($cmd);

    # fly gets annoyed if file doesn't exist, so check that above worked
    if (-f "/tmp/bcdg-$x-$y.gif") {
      print A "copy 0,0,0,0,$xsize,$ysize,/tmp/bcdg-$x-$y.gif\n";
    }
  }
}

close(A);

system("fly -q -i /tmp/bdg.fly -o /tmp/bdg1.gif");

# grab all level 4? OSM maps (this isn't as hideous as it looks thanks
# to caching) [only needed to do this once]
sub grab_osm_maps {
  for $lat (-82..82) {
    for $lon (-180..180) {
      debug(osm_map($lat,$lon,4));
    }
  }
}

=item proj4($lat, $lon, $proj, $div, $xsize=800, $ysize=600, &pre=NULL)

Given a cs2cs projection $proj, return the x/y coordinates of $lat,
$lon under $projection scaled by $div, assuming $xsize x $ysize image.

If given, apply pre() to latitude/longitude before peformring transformation

Return -1,-1 if coordinates are off-image.

TODO: calling cs2cs on each coordinate separately is hideously inefficient

=cut

sub proj4 {
  my($lat, $lon, $proj, $div, $xsize, $ysize, $pre) = @_;
  debug("GOT: $lat, $lon, $proj, $div, $xsize, $ysize, $pre");
  unless ($xsize) {$xsize=800;}
  unless ($ysize) {$ysize=600;}

  if ($pre) {
    ($lat, $lon) = &$pre($lat,$lon);
  }

  debug("AFTER ROTATION: $lat,$lon");

  # echoing back $lat/$lon is pointless here, but may be useful later
  # NOTE: +proj=latlon still requires lon/lat order
  my($cmd) = "echo $lon $lat | cs2cs -E -e 'ERR ERR' +proj=latlon +to +proj=$proj 2> /dev/null";
  debug("PCMD: $cmd");
  my($lt, $lo, $x, $y) = split(/\s+/, `$cmd`);

  debug("POSTPROJ: $x/$div, $y/$div");

  # off image?
  # allow a little bit off image
  if (abs($x)>$div*2 || abs($y)>$div*2 || $x eq "ERR") {return -1,-1;}

  # scale
  $x = $xsize/2*(1+$x/$div);
  $y = $ysize/2*(1-$y/$div);

  debug("XY: $x,$y");

  return round($x),round($y);
}

=item latlonrot($lat, $lon, $th, $ax="x|y|z")

Given a latitude/longitude, rotate it $th degrees around the $ax axis.

z-axis: center of earth to north pole
x-axis: center of earth to intersection of prime meridian and equator
y-axis: center of earth to longitude +90, latitude 0 (right hand rule)

NOTE: this inefficiently uses rotdeg() which is sometimes unnecessary;
for example, rotation around the z axis simply adds to longitude and
preservers latitude.

=cut

sub latlonrot {
  my($lat, $lon, $th, $ax) = @_;

  # convert lat/lon to xyz coords (on sphere of radius 1)
  my(@xyz) = sph2xyz($lon, $lat, 1, "degrees=1");
#  debug("OLD",@xyz);
  my(@newxyz);

  # perform the rotation
  my(@matrix) = rotdeg($th, $ax);

  # I know the matrix is 3x3, so this is slightly over kill
  for $row (0..$#matrix) {
    my(@cols) = @{$matrix[$row]};
    for $col (0..$#cols) {
      @newxyz[$row] += $matrix[$row][$col]*$xyz[$col];
    }
  }

  # return to sph coords (ignore radius)
  my($newlon, $newlat) = xyz2sph(@newxyz,"degrees=1");

  # for longitude, [-180,180] is used, not [0,360]
  if ($newlon>=180) {$newlon-=360;}

  return $newlat,$newlon;
}
