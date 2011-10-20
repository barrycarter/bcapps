#!/bin/perl

# creates a 1000x1000 SVG file suitable for testing

require "bclib.pl";

# TODO: better convention for non-temporary /tmp files
open(A,">/tmp/test.svg");

# header
print A << "MARK";
<svg xmlns="http://www.w3.org/2000/svg" version="1.1"
 width="1000px" height="1000px"
 viewBox="0 0 1000 1000"
>
MARK
;

# test transforms
# print A qq!<g transform="scale(4,4)" >\n!;

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
    print A qq!<circle cx="$j" cy="$l" r="2" fill="black" />\n!;

    # and black text (NE of point)
    $textx = $j+5;
    $texty = $l-5;
    print A qq!<text x="$textx" y="$texty" fill="black" style="font-size:15">$j,$l</text>\n!;

  }
}

# print A "</g>\n";
print A "</svg>\n";

close(A);

