#!/bin/perl

# not really FL specific, helps map FetLife users and give canonical
# place names

require "/usr/local/lib/bclib.pl";

# determine what are lat/lon bounds are

%q = str2hash($ENV{QUERY_STRING});

my($wlon,$nlat) = slippy2latlon($q{x},$q{y},$q{zoom},0,0);

# this is technically one pixel past the tile, but that's OK
my($elon,$slat) = slippy2latlon($q{x},$q{y},$q{zoom},256,256);

# this hideous formula derived using Mathematica

sub lat2py {
(2^(-1 + zoom)*(256*Pi - 2^(9 - zoom)*Pi*y - 
   256*Log[Tan[(90*Pi + lat*Pi)/360]]))/Pi


# TODO: simplify formulas below

# determine x/y coords
($x, $y) = ($query{x}/2**$query{zoom}, $query{y}/2**$query{zoom});

# longitude is simply linear
$lonw = $x*360-180;
$lone = ($x+1/2**$query{zoom})*360-180;

# latitude is a bit harder
$latn = -90 + (360*atan(exp($PI - 2*$PI*$y)))/$PI;
$lats = -90 + (360*atan(exp($PI - 2*$PI*($y+1/2**$query{zoom}))))/$PI;



