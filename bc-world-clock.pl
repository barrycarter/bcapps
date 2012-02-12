#!/bin/perl

# An unusual type of world clock


print << "MARK";
<svg xmlns="http://www.w3.org/2000/svg" version="1.1"
 width="600px" height="600px"
 viewBox="0 0 600 600"
>
MARK
;

for $i (0..35) {
  $an = $i*10;
  print qq%<text x="300" y="300" transform="rotate($an 300,300)">$an</text>\n%;
}

print "</svg>\n";
