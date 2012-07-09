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
    ($x, $y) = projection($lat,$lon);

    debug("XY: $x,$y");

    # skip special cases
    # TODO: improve this?
    if ($x == -1) {next;}

    debug("DOING STUFF");

    # position string a little "SE" of dot
    my($sx,$sy) = ($x+5, $y+5);
    print A "string 0,0,0,$sx,$sy,tiny,$lat,$lon\n";

    # line to next east longitude
    my($xe,$ye) = projection($lat, $lon+20);
    if ($xe == -1) {next;}
    print A "line $x,$y,$xe,$ye,255,0,0\n";

    # line to next south latitude
    my($xs,$ys) = projection($lat-15, $lon);
    if ($xs == -1) {next;}
    print A "line $x,$y,$xs,$ys,0,0,255\n";

    # fcircle must come last to avoid being overwritten by lines
    print A "circle $x,$y,5,0,0,0\n";

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
  #  my($x, $y) = split(/\s+/, `echo $lat $lon | cs2cs +proj=latlong +to +proj=ortho`);
  # div for above is 6378137

#  my($x, $y) = split(/\s+/, `echo $lat $lon | cs2cs +unit=km +proj=latlong +to +proj=merc`);
#  my($x, $y) = split(/\s+/, `echo $lat $lon | cs2cs +proj=latlong +unit=km +to +proj=natearth`);

  my($x, $y) = split(/\s+/, `echo $lat $lon | cs2cs +proj=latlong +to +proj=robin`);

#  my($div) = 6378137*4;
#  my($div) = 20*10**6;
  my($div) = 10*10**6;

  # special case
  if ($x eq "*") {return -1,-1;}

  # below is for orthographic projection, but it varies from
  # projection to projection (grumble)
  $x = 400 + $x/$div*400;
  $y = 300 + $y/$div*300;

  return round($x), round($y);
}
