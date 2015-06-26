#!/bin/perl

require "/usr/local/lib/bclib.pl";

# largely from
# https://github.com/alexschrod/freedink-lua/blob/master/contrib/dinkdat_inspect.c
# and
# https://github.com/alexschrod/freedink-lua/blob/88ff3c183b0891abad221c3326a8f24544fb7ba4/contrib/search_script.c

open(A,"dink.dat")||die("Can't open dink.dat, $!");

# first 8 bytes are header
seek(A,21,SEEK_SET);
my($buf);

# 20 bytes at a time

for $y (1..24) {
  for $x (1..32) {
    read(A,$buf,4);
    # ignore true null
    if ($buf=~/^\0*$/) {next;}

    # convert to int (TODO: not just last byte)
    my($num) = ord(substr($buf,3,1));
#    debug("$y, $x: $num");
  }
}

close(A);

open(A,"map.dat")||die("Can't open map.dat, $!");

# each screen is 31280 bytes

# jump to 9th screen

# seek(A,31280*8,SEEK_SET);

# $buf is one screen
# read(A,$buf,31280);

# tiles for screen one
# read(A,$buf,97*4);

for $tile (0..96) {
  read(A,$buf,80);
  debug(substr($buf,20,2));
}

# read the rest
# read(A,$buf,31280-80*96);

# sprites for screen one (NOT screen nine!)
seek(A,8020,SEEK_SET);

for $sprite (0..100) {
  read(A,$buf,220);
  if ($buf=~/^\0+$/) {next;}
  debug("SPRITE $sprite: $buf");
}

die "TESTING";

for $i (0..96) {
  # 4 bytes for tile index and hardness, this is screen 1
  read(A,$buf,4);
  debug("$i: $buf");
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


# Dink allows 96 tiles per screen (eg,
# /usr/share/dink/dink/tiles/Ts02.bmp), but the numbers start at
# multiples of 128 only

# total theoretical tiles: 512 tilescreens, 96 tiles/screen = 49152 tiles

# at 50x50 per tile, 122 megapixels or 11Kx11K image

# or 512 images of 640x480 each
