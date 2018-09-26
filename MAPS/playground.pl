#!/bin/perl

require "/usr/local/lib/bclib.pl";

# GeoTiff testing

use Image::GeoTIFF::Tiled;
 
my $t = Image::GeoTIFF::Tiled->new("/home/user/20180807/GMT_intermediate_coast_distance_01d.tif");

# Dump meta info
$t->print_meta;
 
die "TESTING";
 
# Dump last tile
$t->dump_tile( $t->number_of_tiles - 1 );

# Get an iterator for an arbitrary shape
my $iter = $t->get_iterator_shape( $shape );
# Get a histogram of pixel values
my %c;
$c{$v}++ while ( defined( my $v = $iter->next ) );


die "TESTING";

# given slippy tile + four coords to project it onto, do so efficiently

# example 3,4,2 (z,x,y), western Europe

# the default command:

system("time convert -mattecolor transparent -extent 800x600 -background transparent -matte -virtual-pixel transparent -distort Perspective '0,0,400,25 0,255,400,103 255,0,512,25 255,255,612,103' /var/cache/OSM/3,4,2.png -extent 800x600 /tmp/1.png");

# system("time convert -mattecolor transparent -extent 255x255 -background transparent -matte -virtual-pixel transparent -distort Perspective '0,0,400,25 0,255,400,103 255,0,512,25 255,255,612,103' /var/cache/OSM/3,4,2.png -extent 800x600 /tmp/5.png");

# takes "0.754u 0.074s 0:00.50 164.0%    0+0k 0+16io 0pf+0w"

# noting that min x is 400, subtract 400 from all x vals

# system("convert -mattecolor transparent -extent 800x600 -background transparent -matte -virtual-pixel transparent -distort Perspective '0,0,0,25 0,255,0,103 255,0,112,25 255,255,212,103' /var/cache/OSM/3,4,2.png -extent 800x600 /tmp/2.png");

# noting y min is 25, subtracting that

# system("convert -mattecolor transparent -extent 800x600 -background transparent -matte -virtual-pixel transparent -distort Perspective '0,0,0,0 0,255,0,78 255,0,112,0 255,255,212,78' /var/cache/OSM/3,4,2.png -extent 800x600 /tmp/3.png");

# and killing extent (212x78)

system("time convert -mattecolor transparent -extent 255x255 -background transparent -matte -virtual-pixel transparent -distort Perspective '0,0,0,0 0,255,0,78 255,0,112,0 255,255,212,78' /var/cache/OSM/3,4,2.png -extent 212x78 /tmp/4.png");
