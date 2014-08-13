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

for $i (@draw) {
  my(@objs) = split(/\,|\s/, $i);

  if ($objs[0] eq "line") {
    # convert ra and dec (currently, two coords per object)
    push(@coords, [@objs[1..2], @objs[3..4]]);
  } elsif ($objs[0] eq "fcircle" || $objs[0] eq "setpixel") {
    push(@coords, [@objs[1..2]]);
  } elsif ($objs[0] eq "string") {
    push(@coords, [@objs[4..5]]);
  } else {
    warn("$objs[0]: not handled");
  }
}

my(%coords) = cs2cs([@coords], "merc", sub {$_[0]*15,$_[1];}, sub {$globopts{xwid}*($_[0]/40000000+1), $globopts{ywid}*($_[1]/40000000+1), 0;});

debug(unfold(\%coords));

# now once more through the coords
for $i (@draw) {
  my(@objs) = split(/\,|\s/, $i);

  if ($objs[0] eq "line") {
    # convert ra and dec (currently, two coords per object)
    debug("COORDS: $coords{[$objs[1],$objs[2]]}");

    next;warn("TESTING");
    my(%coords) = %{$hash{"$newra{$objs[1]},$objs[2]"}};
    debug("HASH",%coords);
    push(@coords, @objs[1..4]);
    debug("LION",@objs[1..4]);
  } elsif ($objs[0] eq "fcircle" || $objs[0] eq "setpixel") {
    push(@coords, @objs[1..2]);
  } elsif ($objs[0] eq "string") {
    push(@coords, @objs[4..5]);
  } else {
    warn("$objs[0]: not handled");
  }
}

debug(unfold(\%hash));

# debug(@latlon);
# debug(@coords);

close(A);

# changed for CGI

unless ($globopts{nocgi}) {print "Content-type: image/gif\n\n";}


die "TESTING";
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
  return ((1-$ra/24.)*$globopts{xwid}, (1-($dec+90)/180.)*$globopts{ywid});
}

# draw stars (program-specific subroutine)

sub draw_stars {
  load_stars();
  my(@ret);
  for $i (@stars) {
    # split into ra/dec/mag
    my($ra, $dec, $mag) = split(/\s+/, $i);
    # circle width based on magnitude (one of several possible formulas)
    my($width) = floor(5.5-$mag);
    push(@ret, "fcircle $ra,$dec,$width,255,255,255");
  }
  return @ret;
}

# draw constellation lines (program-specific subroutine)
sub draw_lines {
  # return list, don't print directly
  my(@ret);
  load_stars();

  for $i (split(/\n/,read_file("$gitdir/db/constellations.dat"))) {
    # ignore non digit-digit lines
    unless ($i=~/^(\d+)\s+(\d+)$/) {next;}
    # from star $from to star $to
    my($from,$to) = ($1, $2);
    # find ra/dec of from and to stars
    my($ra1,$dec1) = split(/\s+/, $stars[$from-1]);
    my($ra2,$dec2) = split(/\s+/, $stars[$to-1]);
    push(@ret,"line $ra1,$dec1,$ra2,$dec2,0,0,255");
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
    push(@ret, "fcircle $pos{$i}->{ra},$pos{$i}->{dec},$col{$i}");
    
    # label planets?
    if ($globopts{planetlabel}) {
      my($name) = ucfirst($i);
      push(@ret,"string 255,255,255,".$pos{$i}->{ra}.",".$pos{$i}->{dec}.",tiny,$name");
    }
  }
  return @ret;
}

# draw constellation boundaries
sub draw_boundaries {
  my(@ret);
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
