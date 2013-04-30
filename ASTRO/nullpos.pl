#!/bin/perl

# RA/DEC of moon at 0N 0E at 0000 UTC 01 Jan 2013
use Astro::Nova;
# 1356998400 == 01 Jan 2013 0000 UTC
$jd = Astro::Nova::get_julian_from_timet(1356998400);
$coords = Astro::Nova::get_lunar_equ_coords($jd);
print join(",",($coords->get_ra(), $coords->get_dec())),"\n";

