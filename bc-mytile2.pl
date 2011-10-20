#!/bin/perl

# Copy of bc-mytile.pl that pulls images from an SVG file
push(@INC,"/usr/local/lib");
require "bclib.pl";

# ($r, $g, $b) = (int(rand(256)), int(rand(256)), int(rand(256)));

%query = str2hash($ENV{QUERY_STRING});

($x, $y) = ($query{x}/2**$query{zoom}*1000, $query{y}/2**$query{zoom}*1000);

# how big is each image?
$size = 1000/2**$query{zoom};

# top left corner of each image?
($tx, $ty) = ($x*$size, $y*$size);
# and bottom right
($bx, $by) = ($tx+$size, $ty+$size);

$svg = read_file("images/grid.svg");

# TODO: make this work w/ viewbox-less SVGs?
# TODO: this incorrectly assumes equiangular, not Mercator, projection
$svg=~s/viewBox=\"(.*?)\"/viewbox="$tx $ty $size $size"/;

write_file($svg, "/tmp/mytile2.svg");
system("convert /tmp/mytile2.svg /tmp/mytile2.png");
$png = read_file("/tmp/mytile2.png");

print "Content-type: image/png\n\n$png";


