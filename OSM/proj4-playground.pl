#!/bin/perl

# uses proj4 to do what bc-draw-grid.pl does

require "/usr/local/lib/bclib.pl";

# spacing in degrees
$latspace = 15;
$lonspace = 20;

# this is vaguely bad
open(A,"|cs2cs +proj=latlong +to +proj=ortho > /tmp/p4po.txt");

for ($lat=90; $lat>=-90; $lat-=$latspace) {
  for ($lon=180; $lon>=-180; $lon-=$lonspace) {
    print A "$lat $lon\n";
    push(@coords, "$lat,$lon");
  }
}

close(A);

@output = split(/\n/, read_file("/tmp/p4po.txt"));

for $i (0..$#coords) {
  debug("$i: $coords[$i] $output[$i]");
}


