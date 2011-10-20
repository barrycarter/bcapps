#!/bin/perl

# Copy of bc-mytile.pl that pulls images from an SVG file
push(@INC,"/usr/local/lib");
require "bclib.pl";

# ($r, $g, $b) = (int(rand(256)), int(rand(256)), int(rand(256)));

%query = str2hash($ENV{QUERY_STRING});

($x, $y) = ($query{x}, $query{y});

# how big is each image?
$size = 1000/2**$query{zoom};

debug("$x,$y,$size");

# top left corner of each image?
($tx, $ty) = ($x*$size, $y*$size);
# and bottom right
($bx, $by) = ($tx+$size, $ty+$size);

$svg = read_file("images/grid.svg");

# TODO: make this work w/ viewbox-less SVGs?
# TODO: this incorrectly assumes equiangular, not Mercator, projection
$svg=~s/viewBox=\"(.*?)\"/viewBox="$tx $ty $size $size"/;

write_file($svg, "/tmp/debug.svg");

# <h>temp files? Who needs 'em!</h>
print "Content-type: image/png\n\n";
open(A, "|convert svg:- png:-");
print A $svg;
close(A);

# <h>Stupid shell tricks: "bc-mytile2.pl | tail -n +3 | display -"</h>
