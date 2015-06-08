#!/bin/perl

# not really FL specific, helps map FetLife users and give canonical
# place names

require "/usr/local/lib/bclib.pl";

# determine what are lat/lon bounds are

%query = str2hash($ENV{QUERY_STRING});

# TODO: simplify formulas below

# determine x/y coords
($x, $y) = ($query{x}/2**$query{zoom}, $query{y}/2**$query{zoom});

# longitude is simply linear
$lonw = $x*360-180;
$lone = ($x+1/2**$query{zoom})*360-180;

# latitude is a bit harder
$latn = -90 + (360*atan(exp($PI - 2*$PI*$y)))/$PI;
$lats = -90 + (360*atan(exp($PI - 2*$PI*($y+1/2**$query{zoom}))))/$PI;



