#!/bin/perl

# if you visit test.barrycarter.info/gettile.php this is what returns
# the image you get

require "/usr/local/lib/bclib.pl";

# get google query
%query = str2hash($ENV{QUERY_STRING});

# determine x/y coords
($x, $y) = ($query{x}/2**$query{zoom}, $query{y}/2**$query{zoom});

# determine other useful information

# longitude is simply linear
$lonw = $x*360-180;
$lone = ($x+1/2**$query{zoom})*360-180;
$lonm = ($lonw+$lone)/2;

# latitude is a bit harder
$latn = -90 + (360*atan(exp($PI - 2*$PI*$y)))/$PI;
$lats = -90 + (360*atan(exp($PI - 2*$PI*($y+1/2**$query{zoom}))))/$PI;
$latm = -90 + (360*atan(exp($PI - 2*$PI*($y+0.5/2**$query{zoom}))))/$PI;

# height is constant
$height = ($latn-$lats)/180*$PI*$EARTH_RADIUS;

# width is not
$widthn = ($lone-$lonw)*cos($latn*$DEGRAD)/180*$PI*$EARTH_RADIUS;
$widths = ($lone-$lonw)*cos($lats*$DEGRAD)/180*$PI*$EARTH_RADIUS;

# x and y pixels for YAMC

my($nwx, $nwy) = lonlat2xy($lonw, $latn);
my($sex, $sey) = lonlat2xy($lone, $lats);

$printstr = << "MARK";
X: $nwx - $sex
Y: $nwy - $sey
MARK
;

# hideous...
print "Content-type: image/gif\n\n";
open(A,"|fly -q");

print A << "MARK";
new
size 256,256
setpixel 0,0,0,0,255
rect 0,0,256,256,255,0,0
# dline 0,128,256,128,255,128,0
# dline 128,0,128,256,255,128,0
MARK
;

$y=0;

for $i (split(/\n/, $printstr)) {
  print A "string 255,255,255,2,$y,giant,$i\n";
  $y+=20;
}

close(A);

# for YAMC, convert lon, lat to x pixel, y pixel rounded to nearest number

sub lonlat2xy {

  my($lon, $lat) = @_;

  my($x) = sprintf("%.0f", (43199+240*$lon)/2);
  my($y) = sprintf("%.0f", (21599-240*$lat)/2);

  return ($x, $y);
}


