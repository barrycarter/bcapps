#!/bin/perl

# draws a latitude/longtiude grid that's modified in some way (part of
# larger attempt to create mercator maps w/ arbitrary 'north pole' and
# otherwise 'zoomed' maps); future idea is to use slippy tiles (OSM)
# and not try to recreate everything myself
# --gridonly: only draw the grid (useful for testing)
# --nogrid: don't draw the grid (useful for testing)
# --nogridstring: don't print most strings on the grid

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
$zoomtile = 4;

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

# $proj = "ortho"; $div = 6378137; $pre = \&pre;
$proj = "merc"; $div = 20000000; $pre = \&pre;
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

    # quadrangle for this grid
    @quad = quadrangle($lat,$lon,$lat+$latspace,$lon+$lonspace);
    debug("Sending $lat,$lon,etc");

    # if none, do nothing
    unless (@quad) {next;}

    debug("QUAD",@quad);

    # what quad returns
    # <h>dirty variable name, hee hee</h>
    ($nwx, $nwy, $nex, $ney, $swx, $swy, $sex, $sey) = @quad;

    # the lines we want (we only draw the nw-touching lines, the others will
    # be drawn by other lat/lon
    print A "line $nwx,$nwy,$nex,$ney,255,0,0\n";
    print A "line $nwx,$nwy,$swx,$swy,0,0,255\n";
    # string
    unless ($globopts{nogridstring}) {
      $strx = $nwx+5;
      $stry = $nwy+5;
      print A "string 0,0,0,$strx,$stry,tiny,$lat,$lon\n";
    }
  }
}

close(A);

die "TESTING";

# now to use the values we just calced
for ($lat=90; $lat>=-90; $lat-=$latspace) {
  # TODO: this is terrible way of skipping grid
  if ($globopts{nogrid}) {next;}
  for ($lon=180; $lon>=-180; $lon-=$lonspace) {
    my($x,$y) = split(/\,/,$proj4{"$lat,$lon"});
    if ($x == -1) {next;}

    # position string a little "SE" of dot
unless ($globopts{nogridstring}) {
    my($sx,$sy) = ($x+5, $y+5);
    print A "string 0,0,0,$sx,$sy,tiny,$lat,$lon\n";
}

    # same lat, east long
    $lone = $lon+$lonspace;
    if ($lone>180){$lone-=360;}
    my($xe,$ye) = split(/\,/, $proj4{"$lat,$lone"});
    unless ($xe == -1) {
    print A "line $x,$y,$xe,$ye,255,0,0\n";
  }

    # line to next south latitude
    $lats = $lat-$latspace;
    my($xs,$ys) = split(/\,/, $proj4{"$lats,$lon"});
    unless ($xs == -1 || $lats<-90) {
    print A "line $x,$y,$xs,$ys,0,0,255\n";
  }

    # position of next point (for testing)
    ($xn,$yn) = split(/\,/,$proj4{"$lats,$lone"});

    # check to see where "halfway SE" point would map
    $latm = ($lat+$lats)/2.;
    $lonm = ($lon+$lone)/2.;

    my($xm,$ym) = proj4($latm, $lonm, $proj, $div, $xsize, $ysize, $pre);

    if (($xm-$xn)*($xm-$x)>0 && $xn!=-1 && $xm!=-1) {
      # this shouldn't happen, means xm is not between x and xn
      print A "string 255,0,0,$xm,$ym,tiny,$latm,$lonm\n";
      debug("X: $latm/$lonm ($lat/$lon to $lats/$lone): $x,$xm,$xn");
    }


#    if (($xm-$xs)*($xm-$x)>0) {
#      debug("XM: $xm, vs $x, $xs");
#    }

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
	# how we would map this border
	($myx, $myy) = proj4($lat,$lon,$proj,$div,$xsize,$ysize,$pre);

	if ($myx==-1 || $myy==-1) {
	  # can't use 'last' here, too deeply nested
	  $taint{$x}{$y} = 1;
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
    debug("CONVERTING: $x,$y zoom $zoomtile");
    $cmd = "convert -mattecolor transparent -extent ${xsize}x$ysize -background transparent -matte -virtual-pixel transparent -distort Perspective $distort /var/cache/OSM/$zoomtile,$x,$y.png /tmp/bcdg-$x-$y.gif";
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
  debug("proj4($lat, $lon, $proj, $div, $xsize, $ysize, $pre)");
  unless ($xsize) {$xsize=800;}
  unless ($ysize) {$ysize=600;}

  if ($pre) {
    ($lat, $lon) = &$pre($lat,$lon);
  }

  # echoing back $lat/$lon is pointless here, but may be useful later
  # NOTE: +proj=latlon still requires lon/lat order
  my($cmd) = "echo $lon $lat | cs2cs -E -e 'ERR ERR' +proj=latlon +to +proj=$proj 2> /dev/null";
  my($lt, $lo, $x, $y) = split(/\s+/, `$cmd`);

  # off image?
  # allow a little bit off image
  if (abs($x)>$div*2 || abs($y)>$div*2 || $x eq "ERR") {return -1,-1;}

  # scale
  $x = $xsize/2*(1+$x/$div);
  $y = $ysize/2*(1-$y/$div);

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

=item quadrangle($slat, $wlon, $nlat, $elon)

Given a SW and NE latitude/longitude, return the quadrangle (four x/y)
points that this projection maps them to.

Similar to calling proj4 multiple times, but uses caching, and checks
that the quadrangle actually "makes sense" (is a true polygon) before
returning it

%proj4 is a global variable

=cut

sub quadrangle {
  my(%arg);
  ($arg{slat}, $arg{wlon}, $arg{nlat}, $arg{elon}) = @_;
  my($minx,$maxx,$miny,$maxy) = (+Infinity,-Infinity,+Infinity,-Infinity);
  my(@ret);

  # impossible lats/lons?
  if (max(abs($arg{slat}),abs($arg{nlat}))>90) {
    debug("LATITUDE out of range");
    return;
  }

  if (max(abs($arg{wlon}),abs($arg{elon}))>180) {
    debug("LONGITUDE out of range");
    return;
  }

  # compute all four corners (we'll need them anyway)
  for $lat ("nlat","slat") {
    for $lon ("wlon","elon") {
      my($rlat, $rlon) = ($arg{$lat}, $arg{$lon});

      unless (@{$proj4{$rlat}{$rlon}}) {
	@{$proj4{$rlat}{$rlon}} = proj4($rlat, $rlon, $proj, $div, $xsize, $ysize, $pre);
      }

      @ans = @{$proj4{$rlat}{$rlon}};
#      debug("ANS",@ans,"PR",@{$proj4{$rlat}{$rlon}});

	# if even one of these is invalid, return nothing
	if ($ans[0]==-1) {
	  debug("proj4($rlat,$rlon) returned -1");
	  return;
	}

      debug("ANS IS",@ans);

	# update max/min
	# TODO: must be better way to do this (sorting?)
	$minx = min($minx,$ans[0]);
	$maxx = max($maxx,$ans[0]);
	$miny = min($miny,$ans[1]);
	$maxy = max($maxy,$ans[1]);

      push(@ret,@ans);

	debug("CORNER: $rlat/$rlon",@ans);
      }
  }

  #      debug("FOR $rlat/$rlon:",@{$proj4{$rlat}{$rlon}});

  # for testing, see if midpoint is inside the quadrangle (it should be)
  # special case for lon straddling +-180
  my($mlon) = ($arg{wlon}+$arg{elon})/2;
  if ($arg{elon} < $arg{wlon}) {
    $mlon+=180;
    if ($mlon>180) {$mlon-=360;}
  }

  my($mlat) = ($arg{slat}+$arg{nlat})/2;

  # TODO: recalculating this is probably bad
  my($mx,$my) = proj4($mlat, $mlon, $proj, $div, $xsize, $ysize, $pre);

  # betweenness testing
  if ($mx < $minx || $mx > $maxx) {
    debug("X $mx midpoint not between $minx and $maxx");
    return;
  }

  if ($my < $miny || $my > $maxy) {
    debug("Y midpoint not between miny and maxy");
    return;
  }

  # all looks well
  debug("RETURNING size $#ret",@ret);
  return @ret;
}

# TODO: move this to bclib.pl

=item signum($x)

Returns the sign (not sine) of $x

=cut

sub signum {
  my($x) = @_;
  if ($x>0) {return 1;}
  if ($x<0) {return -1;}
  return 0;
}
