#!/bin/perl

# A rewrite of bc-starmap.pl that creates a star "chart" not a map
# (plan to use proj4)

# A simple starmap w/ HA-Rey style constellations (see
# db/constellations.db and db/radecmag.asc for data).

# Constellation boundary data: http://cdsarc.u-strasbg.fr/viz-bin/nph-Cat/html?VI%2F49

# HA Rey star data: http://wackymorningdj.users.sourceforge.net/ha_rey_stellarium.zip

# Slew <h>(does anyone get this reference?)</h> of options:
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
# --info=0 display info about this map [not working]
# --nocgi=0 output raw GIF, no CGI header

# TODO: label bright stars
# TODO: no declination labelling?

require "/usr/local/lib/bclib.pl";
system("mkdir -p /tmp/bcstarchart");
chdir("/tmp/bcstarchart");
$gitdir = "/home/barrycarter/BCGIT/";

# defaults
$now = time();
defaults("xwid=1024&ywid=768&fill=0,0,0&time=$now&stars=1&lines=1&planets=1&planetlabel=1&info=0&gridlabel=1");

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

# the list of things to draw
my(@draw);
if ($globopts{lines}) {push(@draw,draw_lines());}
if ($globopts{boundary}) {push(@draw,draw_boundaries());}
if ($globopts{stars}) {push(@draw,draw_stars());}
if ($globopts{planets}) {push(@draw,draw_planets());}
if ($globopts{info}) {push(@draw,draw_info());}
if ($globopts{grid}) {push(@draw,draw_grid());}

# list of coords to translate
my(@coords);

# the position in which coordinates (ra/dec) start for various objects
# (the second coordinate, dec, is immediately after the first)
my(%pos) = ("line" => [1,3], "circle" => [1], "fcircle" => [1],
	    "setpixel" => [1], "string" => [4]);

for $i (@draw) {
  my(@objs) = split(/\,|\s/, $i);
  for $j (@{$pos{$objs[0]}}) {push(@coords, [$objs[$j], $objs[$j+1]]);}
}

# my(%coords) = cs2cs([@coords], "merc", \&pre, sub {$globopts{xwid}*(-$_[0]/40000000+0.5), $globopts{ywid}*(-$_[1]/5000000+0.5), 0;});

my(%coords) = cs2cs([@coords], "eqc", \&pre, \&post);

# my(%coords) = cs2cs([@coords], "ortho", \&pre, \&post);

# temporary "post" function to fix coords
sub post {
  my($x,$y) = @_;
  if ($x eq "ERR") {return -1,1;}
  my($div) = 20037508.34; # for equiangular
#  return $globopts{xwid}*(-$x/$div/2+0.5), $globopts{ywid}*(-$y/$div*4+0.5);
  return $globopts{xwid}*(-$x/$div/2+0.5), $globopts{ywid}*(-$y/$div+0.5);
}

# temporary "pre" function
sub pre {
  my($ra,$dec) = @_;
  my($lat, $lon) = latlonrot($dec, $ra*15, +0*23.45, "x");
  return $lon+180,$lat;
}

# my(%coords) = cs2cs([@coords], "robin", sub {$_[0]*15,$_[1];}, sub {$globopts{xwid}*(-$_[0]/17005833+0.5), $globopts{ywid}*(-$_[1]/17005833+0.5), 0;});

# TODO: don't plot off-canvas points
# now once more through the coords
for $i (@draw) {
  debug("LINE: $i");
  # if object lies off screen, don't print it
  my($taint) = 0;
  my(@objs) = split(/\,|\s/, $i);

  for $j (@{$pos{$objs[0]}}) {
    debug("BEFORE: $objs[$j], $objs[$j+1]");
    ($objs[$j], $objs[$j+1]) = @{$coords{"$objs[$j],$objs[$j+1]"}};
    debug("AFTER: $objs[$j], $objs[$j+1]");
    if ($objs[$j] < 0 || $objs[$j] > $globopts{xwid} ||
	$objs[$j+1] < 0 || $objs[$j+1] > $globopts{ywid}) {
      $taint = 1;
    }
  }

  unless ($taint) {
  # lines that go "backwards"
  if ($objs[0] eq "line" && abs($objs[1]-$objs[3])>$globopts{xwid}/2) {next;}
  print A $objs[0]," ",join(",",@objs[1..$#objs]),"\n";}
}

close(A);

# changed for CGI

unless ($globopts{nocgi}) {print "Content-type: image/gif\n\n";}

system("fly -q -i map.fly");

# load stars into *global* hash (used by other subroutines) just once
sub load_stars {
  if (%stars) {return;}
  for $i (sqlite3hashlist("SELECT hipp, ra/15 AS ra, dec, mag FROM stars WHERE
mag<5.7", "/home/barrycarter/BCGIT/BCINFO3/sites/DB/bchip.db")) {
    for $j (keys %$i) {$stars{$i->{hipp}}{$j} = $i->{$j};}
  }
}

# draw stars (program-specific subroutine)

sub draw_stars {
  load_stars();
  my(@ret);
  for $i (keys %stars) {
    my($width) = floor(5.5-$stars{$i}{mag});
    push(@ret, "fcircle $stars{$i}{ra},$stars{$i}{dec},$width,255,255,255");
  }
  return @ret;
}

# draw constellation lines (program-specific subroutine)
sub draw_lines {
  # return list, don't print directly
  my(@ret);
  load_stars();

  for $i (split(/\n/,read_file("$gitdir/ASTRO/constellationship.fab"))) {
    my(@constdata) = split(/\s+/, $i);
    # starting at 3rd item (index 2) and going in pairs
    for ($j=2; $j<=$#constdata; $j+=2) {
      push(@ret,"line $stars{$constdata[$j]}{ra},$stars{$constdata[$j]}{dec},$stars{$constdata[$j+1]}{ra},$stars{$constdata[$j+1]}{dec},0,0,255");
      debug("J: $constdata[$j] to $constdata[$j+1]");
    }
  }
  return @ret;
}

# draw planets
sub draw_planets {
  my(@ret);
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
    # convert ra back to ra format, not degrees
    $pos{$i}->{ra}/=15;
    push(@ret, "fcircle $pos{$i}->{ra},$pos{$i}->{dec},$col{$i}");

    # label planets?
    if ($globopts{planetlabel}) {
      my($name) = ucfirst($i);
      push(@ret,"string 255,255,255,$pos{$i}->{ra},$pos{$i}->{dec},tiny,$name");
    }
  }
  return @ret;
}

# draw constellation boundaries
sub draw_boundaries {
  my(@ret);
  my(%bounds);
  my($data) = read_file("$gitdir/ASTRO/constellations_boundaries.dat");
  while ($data=~s/(.*?)(\d+)\s+([A-Z]{3})\s+([A-Z]{3})//s) {
    my($data1) = $1;
    my(@arr) = split(/\s+/,trim($data1));
    for ($i=1; $i<=$#arr; $i+=2) {
      push(@ret, "setpixel $arr[$i],$arr[$i+1],255,0,0");
    }
  }

  return @ret;

  die "TESTING";
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
    push(@ret, "setpixel $ra,$dec,255,0,0");
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
      my($x,$y) = (($minra+$maxra)/2,($mindec+$maxdec)/2);
      push(@ret, "string 255,255,255,$x,$y,tiny,$i");
    }
  }
  return @ret;
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
  my(@ret);

  # TODO: the ecliptic should be a separate calculation
  for ($ra=0; $ra<=24; $ra+=1/15.) {
    my($dec) = sin($ra*15*$DEGRAD)*23.45;
    debug("RADEC: $ra/$dec");
    push(@ret, "setpixel $ra,$dec,255,255,255");
  }


  # declination grid
  # TODO: add labels
  for ($dec=-90; $dec<=90; $dec+=10) {
    for ($ra=0; $ra<=24; $ra+=1/15.) {
      push(@ret, "setpixel $ra,$dec,64,64,64");
    }
  }

  # label at declination closest to zenith (rounded to 10 degrees)
  my($decmark) = round($globopts{lat}/10.)*10;

  # RA grid
  for ($ra=0; $ra<=24; $ra+=1) {
    for ($dec=-90; $dec<=90; $dec+=1) {
      push(@ret, "setpixel $ra,$dec,64,64,64");
      # label at equator
      # TODO: not convinced this is best spot; antimap of zenith maybe?
      if ($dec==$decmark && $globopts{gridlabel}) {
	push(@ret, "string 64,64,64,$x,$y,tiny,${ra}h");
      }
    }
  }
  return @ret;
}

# TODO: put this into bclib.pl

=item cs2cs(\@lonlat, $proj, \&pre, \&post, $options)

Given a list of longitude/latitudes (each entry being a list of two
elements), return the mapping of these longitude/latitudes under cs2cs
projection $proj as a hash such that the return value is a hash that
converts these pairs to triples [x,y,z]

&pre: apply this function (expected to take two values) to $lon, $lat
before converting

&post: apply this function (expected to take three values) to x/y/z
before returning

=cut

sub cs2cs {
  my($listref, $proj, $pre, $post) = @_;
  my(@str);
  my(@lonlat) = @{$listref};
  my(%rethash);
  my($count) = 0;

  # write data to file
  for $i (@lonlat) {
    my(@coords) = @$i;
    # apply the $pre function
    if ($pre) {@coords=&$pre(@coords);}
    push(@str, join(" ",@coords));
  }

  my($tmpfile) = my_tmpfile2();
  write_file(join("\n",@str)."\n", $tmpfile);

  my($out,$err,$res) = cache_command("cs2cs -e 'ERR ERR' +proj=lonlat +to +proj=$proj < $tmpfile","age=86400");
  for $i (split(/\n/,$out)) {
    # xyz values
    my(@fields) = split(/\s+/,$i);
    # apply post
    if ($post) {@fields = &$post(@fields);}
    # we need the original lon/lat (before translation) for hash
    # TODO: can't seem to make hash key an array?
    $rethash{join(",",@{$lonlat[$count++]})} = [@fields];
  }
  return %rethash;
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

