#!/bin/perl

# Given an "interpolation output" (see bc-approx-sun-ra-dec.m),
# rewrite as a JavaScript object that ca be assigned to a variable

# --name: if given, assign object to this variable

# NOTE: this program is a "glue" hack, not really well documented

require "/usr/local/lib/bclib.pl";

my($data, $file) = cmdfile();

# get rid of the first and last braces

$data=~s/^\{\s*//;
$data=~s/\}\s*$//;

# first five entries are special

my($minX, $maxX, $intLength, $numPts, $intOrder, $coeffs) = 
 split(/\,\s*/, $data, 6);

if ($globopts{name}) {print "let $globopts{name} = \n";}

# some of these numbers are redundant, but that's OK

print "{minX: $minX, maxX: $maxX, intLength: $intLength, 
 numPts: $numPts, intOrder: $intOrder, coeffs: \n";

$coeffs=~s/\{/[/g;
$coeffs=~s/\}/]/g;
$coeffs=~s/\s//g;

print "$coeffs};\n";






