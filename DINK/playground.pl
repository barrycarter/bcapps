#!/bin/perl

require "/usr/local/lib/bclib.pl";

# largely from
# https://github.com/alexschrod/freedink-lua/blob/master/contrib/dinkdat_inspect.c
# and
# https://github.com/alexschrod/freedink-lua/blob/88ff3c183b0891abad221c3326a8f24544fb7ba4/contrib/search_script.c

debug("READING FIE");

my($all) = read_file("map.dat");

debug("DONE READING FIE");

# chunks

debug(substr($all,1,31280));

# short = 16 bit

# tile = 2 bytes for tile, 2 bytes for hardness

# 96 tiles + 1 empty tile per screen, screen = 31280 bytes

# so first 388 bytes of each chunk = bitmap (+ hardness?)



