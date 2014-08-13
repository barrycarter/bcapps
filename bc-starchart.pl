#!/bin/perl

# A rewrite of bc-starmap.pl that creates a star "chart" not a map
# (plan to use proj4)

# A simple starmap w/ HA-Rey style constellations (see
# db/constellations.db and db/radecmag.asc for data).

# Constellation boundary data: http://cdsarc.u-strasbg.fr/viz-bin/nph-Cat/html?VI%2F49

# Slew of options:
#
# --xwid=1024 x width
# --ywid=768 y width
# --fill=0,0,0 fill color (as r,g,b) (or "transparent" for transparent)
# --stars=1 draw stars
# --lines=1 draw constellation lines
# --planets=1 draw planets (sun/moon are considered planets)
# --planetlabel=1 label planets
# --boundary=0 draw constellation boundaries
# --labelcons=0 label constellations when boundaries are drawn
# --grid=0 draw ra/dec grid
# --gridlabel=1 if drawing ra/dec grid, label it
# --info=1 display info about this map
# --nocgi=0 output raw GIF, no CGI header

# TODO: label bright stars
# TODO: no declination labelling?

require "/usr/local/lib/bclib.pl";
system("mkdir -p /tmp/bcstarchart");
chdir("/tmp/bcstarchart");
$gitdir = "/home/barrycarter/BCGIT/";

# proj4 stuff
# $proj = "ortho"; $div = 6378137; $pre = \&pre;

# defaults
$now = time();
defaults("xwid=1024&ywid=768&fill=0,0,0&time=$now&stars=1&lines=1&planets=1&planetlabel=1&info=1&gridlabel=1");

# write to fly file
open(A, ">map.fly");

# create a blank map (circle and graticule)

if ($globopts{fill}=~/transparent/) {
  # hideous way to add transparent line to fly
  $globopts{fill}="0,0,0\ntransparent 0,0,0\n";
}

print A << "MARK";
new
size $globopts{xwid},$globopts{ywid}
fill 0,0,$globopts{fill}
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
  debug("GOT: $ra/$dec");
  return ((1-$ra/24.)*$globopts{xwid}, (1-($dec+90)/180.)*$globopts{ywid});
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

    # if the absolute value is greater than half the screen size, ignore
    if (abs($x1-$x2)>$globopts{xwid}/2||abs($y1-$y2)>$globopts{ywid}/2) {next;}

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
      # TODO: fix for nonconvex constellations
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
  print A "string 255,255,255,0,$y,small,Source: s.u.94y.info\n";
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

  # label at declination closest to zenith (rounded to 10 degrees)
  my($decmark) = round($globopts{lat}/10.)*10;
  debug("DECMARK: $decmark");

  # RA grid
  for ($ra=0; $ra<=24; $ra+=1) {
    for ($dec=-90; $dec<=90; $dec+=1) {
      my($x,$y) = radec2xy($ra, $dec);
      if ($x<0 && $y<0) {next;}
      print A "setpixel $x,$y,64,64,64\n";
      # label at equator
      # TODO: not convinced this is best spot; antimap of zenith maybe?
      if ($dec==$decmark && $globopts{gridlabel}) {
	print A "string 64,64,64,$x,$y,tiny,${ra}h\n";
      }
    }
  }
}

# TODO: put this into bclib.pl

=item cs2cs(\@lonlat, $proj, $options)

Given a list of longitude/latitudes (each entry being "lon,lat" as a
literal string with a comma in it), return the mapping of these
longitude/latitudes under cs2cs projection $proj as a hash such that:

$rethash{"$lon,$lat"}{x} = the x coordinate of the transform
$rethash{"$lon,$lat"}{y} = the y coordinate of the transform
$rethash{"$lon,$lat"}{z} = the z coordinate of the transform

A simple wrapper around cs2cs.

$options: [NOT YET IMPLEMENTED]

  fx=f: apply the function f to the x coordinates before returning
  fy=f: apply the function f to the y coordinates before returning
  fz=f: apply the function f to the z coordinates before returning

=cut

sub cs2cs {
  my($listref, $proj, $options) = @_;
  # by default, apply the id function to x,y,z
  my(%opts) = parse_form("fx=id&fy=id&fz=id&$options");
  my(@lonlat) = @{$listref};
  my($str);
  my(%rethash);
  my(%iscoord);

  # write data to file
  for $i (@lonlat) {
    $i=~s/,/ /;
    $str .= "$i\n";
  }

  my($tmpfile) = my_tmpfile2();
  write_file($str, $tmpfile);

  my($out,$err,$res) = cache_command("cs2cs -E -e 'ERR ERR' +proj=lonlat +to +proj=$proj < $tmpfile","age=86400");
  for $i (split(/\n/,$out)) {
    my(@fields) = split(/\s+/,$i);
    $rethash{"$fields[0],$fields[1]"}{x} = $fields[2];
    $rethash{"$fields[0],$fields[1]"}{y} = $fields[3];
    $rethash{"$fields[0],$fields[1]"}{z} = $fields[4];
  }
  return %rethash;
}
