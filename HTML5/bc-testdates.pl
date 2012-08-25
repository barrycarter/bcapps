#!/bin/perl

# puts test dates into an SVG for zooming log timeline

require "/usr/local/lib/bclib.pl";

print << "MARK";
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" id="svg" 
 width="1024px" height="600px" viewbox="-512 -300 1024 600">
 <g id="g">
MARK
;


for($i=-2000;$i<=2000;$i+=100) {
  debug("I: $i");
  if ($i>0) {
    $pos = log($i*365.2425*86400);
  } elsif ($i<0) {
    $pos = -log(-$i*365.2425*86400);
  } else {
    $pos = 0;
  }

  debug("POS: $pos");

  print qq%<text x="$pos" y="0" fill="black" style="font-size:015">$i</text>\n%;

}

print "</g></svg>\n";
