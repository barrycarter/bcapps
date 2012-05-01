#!/bin/perl

# A simple starmap w/ HA-Rey style constellations (see
# db/constellations.db and db/radecmag.asc for data).

# Constellation boundary data: http://cdsarc.u-strasbg.fr/viz-bin/nph-Cat/html?VI%2F49

# Slew of options:
# -xwid=800 x width
# -ywid=600 y width
# -fill=0,0,0 fill color (as r,g,b)

push(@INC,"/usr/local/lib");
require "bclib.pl";
chdir(tmpdir());

# defaults
defaults("xwid=800&ywid=600&fill=0,0,0");

# we use these a LOT, so putting them into global vars
($xwid, $ywid) = ($globopts{xwid}, $globopts{ywid});

# half width and height
$halfwid = $xwid/2;
$halfhei = $ywid/2;

# minimum dimension (so circle fits)
$mind = min($xwid, $ywid);

# the X graticule starts at $xwid/2-$mind/2, ends at $xwid/2+$mind/2
($xs, $xe) = ($xwid/2-$mind/2, $xwid/2+$mind/2);

# similarly for the y graticule
($ys, $ye) = ($ywid/2-$mind/2, $ywid/2+$mind/2);

debug("HW: $halfwid, $halfhei");

# write to fly file
open(A, ">map.fly");

# create a blank map (circle and graticule)
print A << "MARK";
new
size $xwid,$ywid
fill 0,0,$globopts{fill}
circle $halfwid,$halfhei,$mind,0,255,0
line $xs,$halfhei,$xe,$halfhei,128,0,0
line $halfwid,$ys,$halfwid,$ye,128,0,0
MARK
    ;




close(A);
system("fly -i map.fly -o map.gif; xv map.gif");

