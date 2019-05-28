#!/bin/perl

# attempts to read a TIFF file without loading it into memory

require "/usr/local/lib/bclib.pl";
use Image::GeoTIFF::Tiled;

# this is a 100GB tiff!

my($tiff) = "$bclib{home}/NOBACKUP/EARTHDATA/ELEVATION/SRTM1/SRTM1-TIFFS/elevation.tif";

my $t = Image::GeoTIFF::Tiled->new($tiff);
 
# Dump meta info
$t->print_meta;

debug($t->pix2tile(1296000, 417600));
 
# Dump last tile
# $t->dump_tile( $t->number_of_tiles - 1 );

die "TESTING";
 
# Get an iterator for an arbitrary shape
my $iter = $t->get_iterator_shape( $shape );
# Get a histogram of pixel values
my %c;
$c{$v}++ while ( defined( my $v = $iter->next ) );
