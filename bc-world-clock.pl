#!/bin/perl

# An unusual type of world clock


print << "MARK";
<svg xmlns="http://www.w3.org/2000/svg" version="1.1"
 width="600px" height="600px"
 viewBox="0 0 600 600"
>
MARK
;

for $i (0..10) {
  $an = $i*36;
  print qq%<text x="300" y="300" transform="rotate($an 300,300)" style="font-size:25">............. $an</text>\n%;
}

print "</svg>\n";
