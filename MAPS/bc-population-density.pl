#!/bin/perl

# does stuff with population density data

use Image::GeoTIFF::Tiled;
require "/usr/local/lib/bclib.pl";

my($fname) = "$bclib{home}/NOBACKUP/EARTHDATA/POPULATION/usa_ppp_2020_UNadj_constrained.tif";

my $t = Image::GeoTIFF::Tiled->new($fname);

debug($t->print_meta);

debug(var_dump("c",$t->corners()));

debug(unfold($t->corners()));
