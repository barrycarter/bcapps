#!/bin/perl

# Copied bc-temperature-voronoi to bc-generic-voronoi to clean it up
# and, more importantly, make it generic for any db/color scheme/etc

# TODO: could genercize to any list of hashs (where hashs contain
# latitude/longitude/color/label/id)

push(@INC,"/usr/local/lib");
require "bclib.pl";
require "bc-kml-lib.pl";

for $i (1..5000) {
#  srand(++$seed*2);
  $x = rand()*360-180;
  $y = rand()*180-90;
  $hashref = {};
  %{$hashref}=(
	       "x" => $x,
	       "y" => $y,
	       "color" => hsv2rgb(rand(),1,1,"kml=1&opacity=80"),
	       "label" => "$x,$y",
	       "id" => ++$n
	      );
  push(@data, $hashref);
}

debug("DATA",@data);

$file = voronoi_map(\@data);

system("cp $file /home/barrycarter/BCINFO/sites/TEST/testing.kmz");





