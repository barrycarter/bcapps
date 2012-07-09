#!/bin/perl

# uses proj4 to do what bc-draw-grid.pl does

require "/usr/local/lib/bclib.pl";

# spacing in degrees
$latspace = 15;
$lonspace = 20;

open(A,">/tmp/bdg2.fly");

print A << "MARK";
new
size 800,600
setpixel 0,0,255,255,255
MARK
;

# in theory, could use multiple calls to cs2cs, but this seems more efficient
for ($lat=90; $lat>=-90; $lat-=$latspace) {
  for ($lon=180; $lon>=-180; $lon-=$lonspace) {
    # this is inefficient
    ($x, $y) = projection($lat,$lon);

    # position string a little "SE" of dot
    my($sx,$sy) = ($x+5, $y+5);
    print A "string 0,0,0,$sx,$sy,tiny,$lat,$lon\n";


#    debug($x,$y);

#    print A "$lat $lon\n";
#    push(@coords, "$lat,$lon");
  }
}

close(A);

system("fly -i /tmp/bdg2.fly -o /tmp/bdg2.gif");

die "TESTING";

@output = split(/\n/, read_file("/tmp/p4po.txt"));

for $i (0..$#coords) {
  debug("$i: $coords[$i] $output[$i]");
}

# hideously inefficient wrapper to cs2cs

sub projection {
  my($lat,$lon) = @_;
  my($x, $y) = split(/\s+/, `echo $lat $lon | cs2cs +proj=latlong +to +proj=ortho`);
  # below is for orthographic projection, but it varies from
  # projection to projection (grumble)
  $x = 400 + $x/6378137*400;
  $y = 300 + $y/6378137*300;

  return round($x), round($y);
}
