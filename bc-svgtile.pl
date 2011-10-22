#!/bin/perl

# Overlay google map w/ given SVG of nominal size 1024x1024
# NOTE: this is slower than most other techniques and is just for testing
# TODO: compensate for Mercator stuff
push(@INC,"/usr/local/lib");
require "bclib.pl";

# TODO: mash together google parameters and my own
%query = str2hash($ENV{QUERY_STRING});
($x, $y) = ($query{x}, $query{y});

# how big is each image?
$size = 1024/2**$query{zoom};

# top left corner of each image?
($tx, $ty) = ($x*$size, $y*$size);
# and bottom right
($bx, $by) = ($tx+$size, $ty+$size);

# TODO: make this SVG from query-string
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
