#!/bin/perl

# Script where I test code snippets; anything that works eventually
# makes it into a library or real program

# chunks are normally separated with 'die "TESTING";'

push(@INC,"/usr/local/lib");
require "bclib.pl";

bin_volt(13.5, 0.9875, 3/365.2425, .9770);

=item bin_volt($price, $strike, $exp, $under)

Computes the volatility of a binary option, given its current $price,
the $strike price, the years to expiration $exp, and the price of the
underlying instrument $under

NOTE: I realize all my valuations are for "call" style options, but
this is probably OK.

NOTE: will pretty much obsolete nadex-vol.pl (?)

TODO: explain the formula below a bit more

=cut

sub bin_volt {
  my($price, $strike, $exp, $under) = @_;
  return log($strike/$under)/udistr($price/100)/sqrt($exp);
}

die "TESTING";

# testing for "known" values

debug(greeks_bin(.9779, .9625, (1306526400-1306257199)/365.2425/86400, .1341));
debug(greeks_bin(.9780, .9725, 74.74/365.2425/24, .1022));



die "TESTING";

# RPC-XML

# get password
$pw = read_file("/home/barrycarter/bc-wp-pwd.txt"); chomp($pw);

# using raw below so i can cache and stuff

$req=<<"MARK";
<?xml version="1.0"?><methodCall>
<methodName>mt.getRecentPostTitles</methodName>
<params>
<param><value><string>x</string></value></param>
<param><value><string>admin</string></value></param>
<param><value><string>$pw</string></value></param>
<param><value>9999999999</value></param>
</params>
</methodCall>
MARK
;

write_file($req,"/tmp/rpc1.txt");
system("curl -o /tmp/rpc2.txt --data-binary \@/tmp/rpc1.txt http://wordpress.barrycarter.info/xmlrpc.php");

die "TESTING";

$xvals = [1,2,3,4,5,6];
$yvals = [1,8,27,64,125,216];

@xvals=@{$xvals};
@yvals=@{$yvals};

for $i (2..5) {

  # slopes in this, next, prev interv
  $sf = $yvals[$i+1]-$yvals[$i];
  $st = $yvals[$i]-$yvals[$i-1];
  $sp = $yvals[$i-1]-$yvals[$i-2];

  # second derv = average of forward and backward change
  $sd = ($sf-$sp)/2;

  # if this interval is (-.5,+.5), this is quadratic
  $x = 0;
  $test = $sd/2*$x*$x + ($yvals[$i+1]-$yvals[$i])*$x +
 (4*$yvals[$i]+4*$yvals[$i+1] - $sd)/8;
  debug("$x -> $test");
 


}


die "TESTING";

debug(hermite(2.5, $xvals, $yvals));

for $i (100..600) {
  $x = $i/100;
  $h = hermite($x, $xvals, $yvals);
  debug("A",$yvals[floor($x)],$yvals[floor($x+1)],$yvals[floor($x+2)]);
  $hp = h00($x-floor($x))*$yvals[floor($x-1)] +
    h01($x-floor($x))*$yvals[floor($x)];

  debug("HP:", $h-$hp);

#  print $x," ", $h-$hp,"\n";
#  print $x," ", $h-$hp,"\n";
}

die "TESTING";

for $i (0..60) {
  ($ra,$dec) = position("sun", 1305936000+86400*$i);
  print "$dec\n";
}

die "TESTING";


# NOTE: graphs of the hermite functions look fine, so its got to be
# the way I'm taking the slope

for $i (0..100) {
  print h11($i/100)."\n";
}

die "TESTING";

for $i (0..100) {
  print hermite(3+$i/100, $xvals, $yvals);
  print "\n";
}

die "TESTING";

# debug(position("moon"));

debug(position("sun", 1305936000));

die "TESTING";

%points = (
 "Albuquerque" => "35.08 -106.66",
 "Paris" => "48.87 2.33",
 "Barrow" => "71.26826 -156.80627",
 "Wellington" => "-41.2833 174.783333",
 "Rio de Janeiro" => "-22.88  -43.28"
);

$EARTH_CIRC = 4.007504e+7;
$r1 = $EARTH_CIRC/2;

# the dividing circle between two points is a circle w/ center on earth

system("cp /usr/local/etc/sun/gbefore.txt /home/barrycarter/BCINFO/sites/TEST/playground.html");

open(A, ">>/home/barrycarter/BCINFO/sites/TEST/playground.html");

$hue = -1/8;

for $i (sort keys %points) {
  $hue += 1/8;
  for $j (sort keys %points) {
    if ($i eq $j) {next;}

    # don't double do
    if ($done{$i}{$j}) {next;}
    $done{$j}{$i} = 1;

    # vector between cities
    ($lat1, $lon1) = split(/\s+/, $points{$i});
    ($lat2, $lon2) = split(/\s+/, $points{$j});

    ($x1, $y1, $z1) = sph2xyz($lon1, $lat1, 1, "degrees=1");
    ($x2, $y2, $z2) = sph2xyz($lon2, $lat2, 1, "degrees=1");
    ($x3, $y3, $z3) = ($x1-$x2, $y1-$y2, $z1-$z2);

    debug("$x3 $y3 $z3");

    # convert back to polar
    ($theta, $phi) = xyz2sph($x3, $y3, $z3, "degrees=1");
    debug("$theta, $phi");

    # fillcolor
    $col = hsv2rgb($hue,1,1);

  print A << "MARK";

pt = new google.maps.LatLng($phi,$theta);

new google.maps.Circle({
 center: pt,
 radius: 10018760,
 map: map,
 strokeWeight: 1,
 strokeColor: "$col",
 fillOpacity: 0,
 fillColor: "#ff0000"
});

MARK
;
  }
}

system("/bin/cat /usr/local/etc/sun/gend.txt >> /home/barrycarter/BCINFO/sites/TEST/playground.html");

sub xyz2sph {
  my($x,$y,$z,$options) = @_;
  my(%opts) = parse_form($options);

  my($r) = sqrt($x*$x+$y*$y+$z*$z);
  my($phi) = asin($z/$r);
  my($theta) = atan2($y,$x);

  if ($opts{degrees}) {
    return $theta*180/$PI, $phi*180/$PI, $r;
  } else {
    return $theta, $phi, $r;
  }
}

die "TESTING";

# final hermite testing pre-production

for $i (1..10) {
  push(@xvals,$i);
  push(@yvals,$i*$i);
}

debug(@xvals,@yvals);

for ($i=1; $i<=10; $i+=.01) {
  print "$i -> ". hermite($i, \@xvals, \@yvals) ."\n";
}

die "TESTING";

$data = read_file("data/moonfakex.txt");
$data2 = read_file("data/moonfakey.txt");
@l = nestify($data);
@l = @{$l[0]};
@l2 = nestify($data2);
@l2 = @{$l2[0]};

for $i (@l) {
  @j = @{$i};
  $j[0]=~s/\*\^(\d+)/e+$1/isg;
  push(@xvals, $j[0]);
  push(@yvals, $j[1]);
}

for $i (@l2) {
  @j = @{$i};
  $j[0]=~s/\*\^(\d+)/e+$1/isg;
  push(@xvals2, $j[0]);
  push(@yvals2, $j[1]);
}

$now = time();
$xcoord = hermite($now, \@xvals, \@yvals);
$ycoord = hermite($now, \@xvals2, \@yvals2);

# computing lunar pos
$ra = atan2($ycoord,$xcoord)/$PI*180;
if ($ra<0) {$ra+=360;}
$dec = (sqrt($xcoord**2+$ycoord**2)-$PI)/$PI*180;

debug("RA/DEC:",$ra,$dec);

# confirmed xcoord is believable, as is y coord

debug("$now/$xcoord/$ycoord");

# debug("X",@xvals,"Y",@yvals);

die "TESTING";

# hermite testing
# <h>No hermits were harmed during these tests</h>

@xvals = @{$l[0][0][2]};
@yvals = @{$l[0][0][3]};

# convert mathematica to perl form
map(s/\*\^/e+/, @xvals);
map(s/\*\^/e+/, @yvals);

# 3.5107128*^9 is April 2nd at 6am is our test case

debug("ALPHA");
debug(hermite(3510755800, \@xvals, \@yvals));

# debug("X",@xvals,"Y",@yvals);

die "TESTING";

sub jd2unix {return(($_[0]-2440587.5)*86400);}
sub unix2jd {return(($_[0]/86400+2440587.5));}

# TODO: cache like crazy!
# moonxyz.txt contains 10 arrays

die "TESTING";

# read_mathematica("data/sunxyz.txt");

$all = read_file("data/sunxyz.txt");

while ($all=~s/[\{\[]([^\{\}\[\]]*)[\}\]]/f2($1)/eisg) {}

# debug($all);
# debug($res[441]);
# debug($res[431]);
# debug($res[400]);
# debug($res[367]);
# debug($res[25]);

# debug("RES",@res);
$all=~s/\s//isg;
debug($all);

@res = f3($all);

debug("RES",unfold(@res));

sub f3 {
  my(@ret);
  my($val) = @_;
  for $i (split(/\,\s*/,$val)) {
    if ($i=~/RES(\d+)/) {
      push(@ret, [f3($res[$1])]);
    } else {
      push(@ret, $i);
    }
  }

  return @ret;
}


# NOTES: only reads (possibly nested) lists, uses static var, returns ref

sub read_mathematica {
  my($file) = @_;
  if ($static{mathematica}{$file}) {return $static{mathematica}{$file};}
  my($data) = read_file($file);

  # only what's between the {}
  $data=~m%(\{.*?\})%isg || warnlocal("No braces: $data");

  # convert mathematica's {} to []
  $data=~tr/\{\}/\[\]/;
  # remove bad chars
  $data=~s/\`//isg;

  debug($data);

  my(@l) = eval($data);
  debug($@);

  debug(@l);

}



die "TESTING";

# use Math::MatrixReal;

# my($a) = Math::MatrixReal->new_random(5, 5);

debug($a);


die "TESTING";

# TESTS
# order is irrelevant
# print convert_time(1001, "%M minutes %S seconds")."\n";
# print convert_time(1001, "%S seconds %M minutes")."\n";

# just in seconds
# print convert_time(1001, "%S seconds")."\n";

# hours and seconds (no minutes)
# print convert_time(3600*7+60*4, "%H hours, %S seconds")."\n";
# with minutes, but weird order
# print convert_time(3600*7+60*4, "%M minutes, %H hours, %S seconds")."\n";

# larger value testing
# below doesn't agree with calendar because of leap year
# print convert_time(time(), "%Y years, %m months, %d days")."\n";
print convert_time(time(), "%Y years, %m months, %d days, %H hours, %M minutes, %S seconds")."\n";
# print convert_time(time(), "%U weeks")."\n";
# print convert_time(time(), "%S seconds plus %U weeks")."\n";
# print convert_time(time(), "%S seconds")."\n";

die "TESTING";

# use Astro::Coord::ECI::Moon;
# my $loc = Astro::Coord::ECI->geodetic (0, 0, 0);
# $moon = Astro::Coord::ECI::Moon->new ();
# @almanac = $moon->almanac($loc, time());

debug(unfold(@almanac));

die "TESTING";

# use PDL::Transform::Cartography;
#        $a = earth_coast();
#        $a = graticule(10,2)->glue(1,$a);
#        $t = t_mercator;
#        $w = pgwin(xs);
#        $w->lines($t->apply($a)->clean_lines());

die "TESTING";


# debug(to_mercator(-85,0,"order=xy"));

debug(from_mercator(0,0));


sub from_mercator {
  my($x, $y, $options) = @_;
  my(%opts) = parse_form($options);
  return atan(sinh($y)), $x*360-180;
}


=item project($lay, $lox, $proj, $dir)

Projects latitude/longitude $lay/$lox to xy coordinates for the
projection $proj; if $dir is 1, does the reverse and converts xy
coordinates to latitude/longitude.

$lax: the latitude or y-coordinate
$loy: the longitude or x-coordinate

(note the order of the xy coordinates are reversed, so that latitude
matches y and longitude matches x)

Note: center of map is 0,0; x and y values range from -0.5 to +0.5

NOT YET DONE!

=cut

sub project {
  my($lay, $lox, $proj, $dir) = @_;

  # this is an ugly way to do this (if/elsif/else)

  # Specifically, google's mercator projection
  if ($proj=~/^merc/) {
    if ($dir) {
      return (atan(sinh($lay)), $lox*360);
    } else {
      return (-1*(log(tan($PI/4+$lay/180*$PI/2))/2/$PI), $lox/360);
    }
  }
}

=item to_mercator($lat,$lon)

Converts $lat, $lon (degrees) to google maps' yx Mercator projects
(top left = 0,0; bottom right = 1,1); can return abs($y)>1 for far
south/north latitudes. Options:

 order=(xy|yx): return coordinates in xy or yx format (latter is default)

NOTE: return order is yx, not xy

=cut

sub to_mercator {
  my($lat,$lon, $options) = @_;
  my(%opts) = parse_form($options);

  my($y) = 1/2-1*(log(tan($PI/4+$lat/180*$PI/2))/2/$PI);
  if ($opts{order} eq "xy") {
    return ($lon+180)/360, $y;
    # else below is actually optional, but omitting it is confusing
  } else {
    return $y,($lon+180)/360;
  }
}




die "TESTING";

@pts = (35.08, -106.66, 48.87, 2.33, 71.26826, -156.80627, -41.2833,
174.783333, -22.88, -43.28);

debug("ALPHA");
debug(unfold(voronoi(\@pts,"infinityok=1")));

die "TESTING";


=item hashlist2sqlite

DOC ME! (but test me first!)

=cut

sub hashlist2sqlite {
  my($hashs, $tabname, $outfile) = @_;
  my(%iskey);
  my(@queries);

  for $i (@{$hashs}) {
    my(@keys,@vals) = ();
    my(%hash) = %{$i};
    for $j (sort keys %hash) {
      $iskey{$j} = 1;
      push(@keys, $j);
      push(@vals, "\"$hash{$j}\"");
    }

    push(@queries, "INSERT INTO $tabname (".join(", ",@keys).") VALUES (".join(", ",@vals).");");
  }

  debug(@queries);
}

exit 1;

die "TESTING";

$all="{this, {is, some, {deeply, nested}, text}, for, you}";

# $all = read_file("data/sunxyz.txt");

# could try to match newline, but this is easier
$all=~s/\n/ /isg;

# <h>It vaguely annoys me that Perl doesn't require escaping curly braces</h>
while ($all=~s/{([^{}]*?)}/handle($1)/seg) {
  $n++;
  debug("AFTER RUN $n, ALL IS:",$all);
}

debug(*$all);

debug("ALL",$all);

debug("ALL",@{$all});


sub handle {
  my($str) = @_;
  debug("Handling $str");
  return \{split(/\,\s*/, $str)};
  debug("L IS:",@l);
  debug("Returning ". \@l);
  return \@l;
}

die "TESTING";

$all="{this, {is, some, {deeply, nested}, text}, for, you}";

while ($all=~s/\{([^{}]*?)\}/f($1)/seg) {
  debug("ALL: $all");
}

sub f {
  my($x) = @_;
  return \$x;
}

debug(*$all);

# sub f {return \{split(",",$_[0])};}

# debug(unfold(@res));


die "TESTING";

debug(project(1,0,"mercator",1));


die "TESTING";

# reading Mathematica interpolation files

$all = read_file("sample-data/manytables.txt");

while ($all=~s/InterpolatingFunction\[(.*?)\]//s) {
  $func = $1;

  # get rid of pointless domain
  # {} are not special to Perl?!
  $func=~s/{{(.*?)}}//;

  # xvals
  $func=~s/{{(.*?)}}//s;
  $xvals = $1;
  debug("XV: $xvals");

  # split and fix
  @xvals=split(/\,|\n/s, $xvals);

  for $i (@xvals) {
    $i=~s/(.*?)\*\^(\d+)/$1*10**$2/iseg;
  }

  debug($func);

}

