#!/bin/perl

# A simple starmap w/ HA-Rey style constellations (see
# db/constellations.db and db/radecmag.asc for data).

# Constellation boundary data: http://cdsarc.u-strasbg.fr/viz-bin/nph-Cat/html?VI%2F49

# Slew of options:
#
# --xwid=1024 x width
# --ywid=768 y width
# --fill=0,0,0 fill color (as r,g,b)
# --time=now draw starmap at this time (GMT)
# --stars=1 draw stars
# --lines=1 draw constellation lines
# --planets=1 draw planets (sun/moon are considered planets)
# --planetlabel=1 label planets
# --boundary=0 draw constellation boundaries
# --labelcons=0 label constellations when boundaries are drawn
# --grid=0 draw ra/dec grid
# --gridlabel=1 if drawing ra/dec grid, label it
# --lat=35.082463 latitude where to draw map
# --lon=-106.629635 longitude where to draw map
# --rot=90 rotate so north is at this many degrees (0 = right, 90 = up)
# --info=1 display info about this map
# --nocgi=0 output raw GIF, no CGI header

# TODO: label bright stars

push(@INC,"/usr/local/lib");
require "bclib.pl";
require "bc-astro-lib.pl";
chdir(tmpdir());
$gitdir = "/home/barrycarter/BCGIT/";

# defaults
$now = time();
defaults("xwid=1024&ywid=768&fill=0,0,0&time=$now&stars=1&lat=35.082463&lon=-106.629635&rot=90&lines=1&planets=1&planetlabel=1&info=1&gridlabel=1");

# we use these a LOT, so putting them into global vars
($xwid, $ywid) = ($globopts{xwid}, $globopts{ywid});

# half width and height
$halfwid = $xwid/2;
$halfhei = $ywid/2;

# minimum dimension (so circle fits)
$mind = min($xwid, $ywid);

# the X graticule starts at $xwid/2-$mind/2, ends at $xwid/2+$mind/2
($xs, $xe) = ($xwid/2-$mind/2, $xwid/2+$mind/2);

# similarly for the y graticule
($ys, $ye) = ($ywid/2-$mind/2, $ywid/2+$mind/2);

debug("HW: $halfwid, $halfhei");

# write to fly file
open(A, ">map.fly");

# create a blank map (circle and graticule)
print A << "MARK";
new
size $xwid,$ywid
fill 0,0,$globopts{fill}
circle $halfwid,$halfhei,$mind,0,255,0
line $xs,$halfhei,$xe,$halfhei,128,0,0
line $halfwid,$ys,$halfwid,$ye,128,0,0
MARK
    ;

# draw stars/lines if requested (lines must preceed stars else they obscure)
if ($globopts{lines}) {draw_lines();}
if ($globopts{boundary}) {draw_boundaries();}
if ($globopts{stars}) {draw_stars();}
if ($globopts{planets}) {draw_planets();}
if ($globopts{info}) {draw_info();}
if ($globopts{grid}) {draw_grid();}

close(A);

# changed for CGI

unless ($globopts{nocgi}) {print "Content-type: image/gif\n\n";}

system("fly -q -i map.fly");

# load stars into *global* array (used by other subroutines) just once
sub load_stars {
  unless (@stars) {
    @stars = split(/\n/,read_file("$gitdir/db/radecmag.asc"));
  }
}

# convert ra/dec to x/y for given arguments to this program, return
# -1,-1 if below horizon

sub radec2xy {
  my($ra, $dec) = @_;
  debug("GOT($ra,$dec)");
  # first, convert to azimuth and elevation for this lat/lon/time
  my($az, $el) = radecazel2($ra, $dec, $globopts{lat}, $globopts{lon}, $globopts{t});
  debug("RETURNING NOT: $az,$el");
  if ($el<0) {return (-1,-1);}

  # polar coordinates: r = distance from center = 90-el ; el=0 -> edge
  my($r) = (90-$el)/90*$mind/2;
  # theta is reversed, because east is left of north when looking up
  # adding requested rotation as well; convert to radians
  my($theta) = -($az+$globopts{rot})*$DEGRAD;

  # convert to Cartesian
  my($x,$y) = ($halfwid + $r*cos($theta), $halfhei + $r*sin($theta));
  return ($x,$y);
}

# draw stars (program-specific subroutine)

sub draw_stars {
  load_stars();

  for $i (@stars) {
    # split into ra/dec/mag
    my($ra, $dec, $mag) = split(/\s+/, $i);
    # convert to x/y
    my($x,$y) = radec2xy($ra,$dec);
    # ignore below horizon
    if ($x<0) {next;}
    # circle width based on magnitude (one of several possible formulas)
    my($width) = floor(5.5-$mag);
    print A "fcircle $x,$y,$width,255,255,255\n";
  }

}

# draw constellation lines (program-specific subroutine)
sub draw_lines {
  load_stars();

  for $i (split(/\n/,read_file("$gitdir/db/constellations.dat"))) {
    # ignore non digit-digit lines
    unless ($i=~/^(\d+)\s+(\d+)$/) {next;}
    # from star $from to star $to
    my($from,$to) = ($1, $2);
    # find ra/dec of from and to stars
    my($ra1,$dec1) = split(/\s+/, $stars[$from-1]);
    my($ra2,$dec2) = split(/\s+/, $stars[$to-1]);

    # find x/y pos of stars above
    my($x1,$y1) = radec2xy($ra1,$dec1);
    my($x2,$y2) = radec2xy($ra2,$dec2);

    # if one part of line out of bounds, ignore
    if ($x1 < 0 || $x2 < 0) {next;}

    print A "line $x1,$y1,$x2,$y2,0,0,255\n";
  }
}

# draw planets
sub draw_planets {
  my(%pos);

  # preferred color and size of planets
  # TODO: very ugly to hardcode this
  # TODO: scale to size of map?
  my(%col) = (
	      "sun" => "10,255,255,0",
	      "moon" => "10,255,255,255",
	      "mercury" => "5,255,128,128",
	      "venus" => "5,0,255,255",
	      "mars" => "5,255,0,0",
	      "jupiter" => "5,0,255,255",
	      "saturn" => "5,255,255,0",
	      "uranus" => "3,0,255,0"
	      );

  # obtain planet positions from db
  my($jd) = jd2unix($now, "unix2jd");
  my(@res) = sqlite3hashlist("SELECT p1.time, p1.planet, p1.type, p1.xinit, p1.slope FROM (SELECT p1.planet,p1.type,MAX(p1.time) AS max FROM planetpos p1 WHERE time<=$jd GROUP BY p1.planet,p1.type) AS t1 JOIN planetpos p1 ON (t1.planet=p1.planet AND t1.max=p1.time AND t1.type=p1.type)", "/home/barrycarter/BCGIT/db/planetpos.db");

  # calculate ra/dec for each planet
  for $i (@res) {
    # the value at current time
    my($val) = ($jd-$i->{time})*$i->{slope}+$i->{xinit};
    $pos{$i->{planet}}{$i->{type}} = $val;
  }

  for $i (sort keys %pos) {
    # xy position of planet (converting degrees to RA)
    my($x,$y) = radec2xy(($pos{$i}->{ra})/15, $pos{$i}->{dec});
    if ($x<0 && $y<0) {next;}
    print A "fcircle $x,$y,$col{$i}\n";
    
    # label planets?
    if ($globopts{planetlabel}) {
      my($name) = ucfirst($i);
      
      # print name on "SE corner" of planet
      my($xname) = $x+2;
      my($yname) = $y+2;

      print A "string 255,255,255,$xname,$yname,tiny,$name\n";
    }
  }
}

# draw constellation boundaries
sub draw_boundaries {
  my(%bounds);
  my(@data) = split(/\n/, read_file("/home/barrycarter/BCGIT/db/constellation_boundaries.dat"));

  # just draw red dots
  for $i (@data) {
    # strip leading spaces
    $i = trim($i);
    # convert "+ 9" to "+9"
    $i=~s/([\+\-])\s+/$1/isg;
    my($ra, $dec, $cname) = split(/\s+/, $i);

    # record ra/dec for this constellation to print label later
    push(@{$bounds{$cname}{ra}}, $ra);
    push(@{$bounds{$cname}{dec}}, $dec);

    # find xy
    my($x,$y) = radec2xy($ra,$dec);
    debug("$ra/$dec/$cname -> $x,$y");
    if ($x<0 && $y<0) {next;}
    # and draw
    print A "setpixel $x,$y,255,0,0\n";
  }

  # now, labels (if desired)
  if ($globopts{labelcons}) {
    for $i (sort keys %bounds) {
      my($minra) = min(@{$bounds{$i}{ra}});
      my($maxra) = max(@{$bounds{$i}{ra}});
      my($mindec) = min(@{$bounds{$i}{dec}});
      my($maxdec) = max(@{$bounds{$i}{dec}});

      # if crossing 0h, fix
      if (abs($minra-$maxra)>=12) {$minra+=24;}

      # find xy of midpoint (not necessarily in constellation: convexity)
      my($x,$y) = radec2xy(($minra+$maxra)/2,($mindec+$maxdec)/2);
      if ($x<0 && $y<0) {next;}
      print A "string 255,255,255,$x,$y,tiny,$i\n";
    }
  }
}

# draw info
sub draw_info {
  my($y)=0;
  for $i (sort keys %globopts) {
    # tmpdir is both long and pointless
    if ($i eq "tmpdir") {next;}
    print A "string 255,255,255,0,$y,small,$i: $globopts{$i}\n";
    $y+=10;
  }
}

# draw grid
sub draw_grid {
  # declination grid
  # TODO: add labels
  for ($dec=-90; $dec<=90; $dec+=10) {
    for ($ra=0; $ra<=24; $ra+=1/15.) {
      my($x,$y) = radec2xy($ra, $dec);
      if ($x<0 && $y<0) {next;}
      print A "setpixel $x,$y,64,64,64\n";
    }
  }

  # RA grid
  for ($ra=0; $ra<=24; $ra+=1) {
    for ($dec=-90; $dec<=90; $dec+=1) {
      my($x,$y) = radec2xy($ra, $dec);
      if ($x<0 && $y<0) {next;}
      print A "setpixel $x,$y,64,64,64\n";
      # label at equator
      # TODO: not convinced this is best spot; antimap of zenith maybe?
      if ($dec==0 && $globopts{gridlabel}) {
	print A "string 64,64,64,$x,$y,tiny,${ra}h\n";
      }
    }
  }
}
