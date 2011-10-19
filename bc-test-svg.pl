#!/bin/perl

# creates a 1000x1000 SVG file suitable for testing

require "bclib.pl";

# TODO: better convention for non-temporary /tmp files
open(A,">/tmp/test.svg");

# header
print A qq!<svg xmlns="http://www.w3.org/2000/svg" version="1.1">\n!;
# print A qq!<g transform="scale(0.001,0.001)")>\n!;

# <h>TODO: choose worse colors</h>

for $i (0..10) {
  $j = $i*100;

  # horizontal lines
  print A qq!<line x1="0" y1="$j" x2="1000" y2="$j" style="stroke:rgb(255,0,0)" />\n!;

  # vertical lines
  print A qq!<line x1="$j" y1="0" x2="$j" y2="1000" style="stroke:rgb(0,0,255)" />\n!;

  for $k (0..10) {
    $l = $k*100;
    debug("K: $k");

    # white circle <h>blue hearts, purple moons, ...</h>
    print A qq!<circle cx="$j" cy="$l" r="2" fill="white" />\n!;

    # and black text (NE of point)
#    $j+=5;
#    $l+=5;
    print A qq!<text x="$j" y="$l" fill="black">$j,$l</text>\n!;

  }
}

# print A "</g>\n";
print A "</svg>\n";

close(A);

