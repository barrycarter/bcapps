#!/bin/perl

require "/usr/local/lib/bclib.pl";

# largely from
# https://github.com/alexschrod/freedink-lua/blob/master/contrib/dinkdat_inspect.c
# and
# https://github.com/alexschrod/freedink-lua/blob/88ff3c183b0891abad221c3326a8f24544fb7ba4/contrib/search_script.c

open(A,"dink.dat")||die("Can't open dink.dat, $!");

# first 8 bytes are header
seek(A,9,SEEK_SET);
my($buf);

# 20 bytes at a time

for $y (1..24) {
  for $x (1..32) {
    read(A,$buf,20);
    debug("$y, $x: $buf");
  }
}

die "TESTING";

my($all) = read_file("map.dat");

debug("DONE READING FIE");

# chunks

debug(substr($all,1,31280));



# short = 16 bit

# tile = 2 bytes for tile, 2 bytes for hardness

# 96 tiles + 1 empty tile per screen, screen = 31280 bytes

# so first 388 bytes of each chunk = bitmap (+ hardness?)

# experiments w/ bored:

# hardwood floor = ts01.bmp, row 1, col 4

# appears to be 80 bytes per tile? [which would mean 391 chunks of 80
# bytes total]

# 30 = black, 19 = wall, 6 = wall/bookcase

# actually 64 tiles per supertile (50x50 each)

# 12x8 layout of 96 tiles per screen,  50x50 per tile


