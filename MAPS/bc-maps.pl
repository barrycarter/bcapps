#!/bin/perl

# a list of maps available from bc-mapserver.pl

our(%maps);

# the root for raster maps (as a squashfs)

my($rroot) = "/mnt/bcmapserver";

# TODO: vector root?

# TODO: check maps actually exist on startup

$maps{climate} = {
   "filename" => "$rroot/climate.bin", "type" => "raster", "size" => "Byte"
};

# using this a library so returning true

true;
