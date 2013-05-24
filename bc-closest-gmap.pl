#!/bin/perl

# Find which portions of globe are closest to given point(s) (Voronoi)

# Note: starting with Paris <h>(the one in France, not Texas)</h> and
# Albuquerque <h>(two major world hubs)</h>; had to add more later;
# min is 5 says qhull [but I was using wrong prog, meant qconvex]

require "/usr/local/lib/bclib.pl";

# latitude and longitude of points
%points = (
 "Albuquerque" => "35.08 -106.66",
 "Paris" => "48.87 2.33",
 "Barrow" => "71.26826 -156.80627",
 "Wellington" => "-41.2833 174.783333",
 "Rio de Janeiro" => "-22.88  -43.28"
);

# convert to 3D
for $i (sort keys %points) {
  ($lat,$lon) = split(/\s+/, $points{$i});
  ($x,$y,$z) = sph2xyz($lon,$lat,1,"degrees=1");
  debug("$i -> $x $y $z");

  # we need to number points for qhull
  $qhull[$n] = "$x $y $z";

  # just in case we need these
  $x[$n] = $x;
  $y[$n] = $y;
  $z[$n] = $z;

  $n++;

}

open(A,">/tmp/qclose.txt");

# 3D points and how many
print A "3\n$n\n";

for $i (0..$#qhull) {
 print A "$qhull[$i]\n";
}

close(A);

# qhull does the real work
# http://www.qhull.org/html/qh-faq.htm#vsphere
# TODO: this doesn't tell what two cities we're separating
# TODO: remove QJ
# @res = `qconvex QJ n < /tmp/qclose.txt`;
# TODO:  can't cache this really, since I use a fixed filename
my($out,$err,$res) = cache_command("qhull Qz v n < /tmp/qclose.txt","age=60");
debug($out);
die "TESTING";
@res = `qhull Qz v n < /tmp/qclose.txt`;
debug(@res);
die "TESTING";

# TODO: really should be using chdir(tmpdir()) universally
open(B,">/home/barrycarter/BCINFO/sites/TEST/gmarkclose.txt");

# first two lines are dull
for $i (2..$#res) {
  # plane equation
  ($a,$b,$c,$d) = split(/\s+/, $res[$i]);

  # d is backwards?
#  $d*=-1;

  # construct a line for each dividing line
  @line = ();

  # for each value of z, compute x and y consistent w/ plane and sphere
  for ($z=-1; $z<=+1; $z+=0.01) {
    # equations courtesy mathematica

    # TODO: hideous use of error flag
    $SQRT_ERROR = 0;
    $x = ($a**2*$d - $a**2*$c*$z - $b*Sqrt(-($a**2*(($d - $c*$z)**2 + $a**2*(-1 + $z**2) + $b**2*(-1 + $z**2)))))/($a*($a**2 + $b**2));
    $y = ($b*$d - $b*$c*$z + Sqrt(-($a**2*(($d - $c*$z)**2 + $a**2*(-1 + $z**2) + $b**2*(-1 + $z**2)))))/($a**2 + $b**2);
    if ($SQRT_ERROR) {next;}

    debug("ABCD: $a $b $c $d");
    debug("FOO: $x $y $z");
    debug("SQ SUM:". ($x**2+$y**2+$z**2));

    # compute distance from given points
    debug("DIST FOO-ABQ: ". (dist($x,$y,$z,$x[0],$y[0],$z[0])));
    debug("DIST FOO-CDG: ". (dist($x,$y,$z,$x[1],$y[1],$z[1])));

    $lon = atan2($y,$x)/$PI*180;
    $lat = asin($z)/$PI*180;
    debug("$x/$y/$z -> $lat/$lon");
    # TODO: this is NOT the correct way to check for "not a number"
    if ($lat eq "nan" || $lon eq "nan") {next;}
    # google API probably doesn't understand 'e' notation
    if ($lat=~/e/ || $lon=~/e/) {next;}
    # push this point onto line
    push(@line, "new google.maps.LatLng($lat, $lon)");
  }

  $innerline = join(",\n", @line);

  # create the line
  print B << "MARK";

var line = [
$innerline
];

var mapline = new google.maps.Polyline({
 path: line,
 strokeColor: "#FF0000",
 strokeOpacity: 1.0,
strokeWeight: 2
});

mapline.setMap(map);

MARK
;
}

# just plain ugly

sub Sqrt {
  my($x) = @_;
  if ($x>0) {return sqrt($x);}
  $SQRT_ERROR = 1;
  return 0;
}

# 3D distance between two points (can be improved/generalized/etc)

sub dist {
  my($x1,$y1,$z1,$x2,$y2,$z2) = @_;
  return sqrt(($x2-$x1)**2 + ($y2-$y1)**2 + ($z2-$z1)**2);
}
