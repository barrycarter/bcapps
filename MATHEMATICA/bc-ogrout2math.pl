#!/bin/perl

# converts a list of polygons (from "ogrinfo -al *.shp") to a
# Mathematica compatible list

require "/usr/local/lib/bclib.pl";

print "{\n";

while (<>) {

  # just the polygons
  unless (s/^\s*polygon\s*\(\((.*?)\)\)\s*$/$1/i) {next;}

  # listify each coordinate
  s/([0-9\.\-]+) ([0-9\.\-]+)/{$1,$2}/g;

  print "{$_},\n";
}

print "}\n";
