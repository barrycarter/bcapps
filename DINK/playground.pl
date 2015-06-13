#!/bin/perl

require "/usr/local/lib/bclib.pl";

# freedinkedit xdotool testing

my($win) = `xdotool search --name dink`;
chomp($win);

# using consistent tmp dir for now
mkdir("/tmp/dink/");
chdir("/tmp/dink/");

# move to top left corner (50 here is excessive)
# commenting out for testing
# for (1..50) {xdotoolkey("Left",$win); xdotoolkey("Up",$win);}

system("xdotool windowraise $win");

for (1..24) {
  $count++;
  xdotoolkey("Return",$win);
  # assuming mouse is safely hidden (but could do mousemove here to be sure)
#  xdotoolkey("Tab",$win);
  system("xwd -id $win > $count.xwd");
  # below can also be Escape
#  xdotoolkey("Tab",$win);
  xdotoolkey("Escape",$win);
  xdotoolkey("Right",$win);
  debug("DONE $count, sleeping");
  sleep(1);
}

die "TESTING";

# not sure why freedinkedit doesn't work with "xdotool key", but
# "holding" key down for a fraction of a second seems to work

# this is really really really ugly and may break so not adding it to bclib.pl

sub xdotoolkey {
  my($key,$win) = @_;
  # using system sleep (not Perl sleep) for hopefully more consistency
  system("xdotool keydown --window $win $key; sleep 0.05; xdotool keyup --window $win $key");
}

die "TESTING";

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

# experiments w/ bored:

# hardwood floor = ts01.bmp, row 1, col 4

# appears to be 80 bytes per tile? [which would mean 391 chunks of 80
# bytes total]

# 30 = black, 19 = wall, 6 = wall/bookcase

# actually 64 tiles per supertile (50x50 each)

# 12x8 layout of 96 tiles per screen,  50x50 per tile


