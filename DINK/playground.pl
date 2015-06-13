#!/bin/perl

require "/usr/local/lib/bclib.pl";

# find and raise freedink edit window
my($win) = `xdotool search --name dink`;
chomp($win);
system("xdotool windowraise $win; xdotool windowfocus $win");

# using consistent tmp dir for now
mkdir("/tmp/dink/");
chdir("/tmp/dink/");

# TODO: this is testing only
system("rm /tmp/dink/*");

# the whole "map"
my($out,$err,$res) = cache_command2("xwd -id $win > wholemap.xwd");
my(%mark);

warn("Caching tile data; if you change maps, use --nocache first time");

# slice main map to find dreaded purple tiles of doom(tm)
# 1943571059b5545ec0ef333dd42cb91740b1615b = sha1 of dreaded tile
for $y (1..24) {
  for $x (1..32) {
    # slice and dice
    my($gx,$gy) = ($x*20-20,$y*20-20);
    # this code should be taken out and shot
    my($out,$err,$res) = cache_command2("convert -crop 20x20+$gx+$gy wholemap.xwd - | sha1sum | grep 1943571059b5545ec0ef333dd42cb91740b1615b","age=3600");
    unless ($res) {$mark{$y}{$x} = 1;}
  }
}

for $i (sort {$a <=> $b} keys %mark) {
  for $j (sort {$a <=> $b} keys %{$mark{$i}}) {
    debug("ROWCOL: $i/$j should be purple");
  }
}

die "TESTING";

# move to top left corner (50 here is excessive)
# commenting out for testing
# for (1..50) {xdotoolkey("Left",$win); xdotoolkey("Up",$win);}

# get wininfo
my($out,$err,$res) = cache_command2("xwininfo -id $win");

# find absolute nw corner
$out=~s/Absolute upper-left X:\s*(\d+)//s;
my($nwx) = $1;
$out=~s/Absolute upper-left Y:\s*(\d+)//s;
my($nwy) = $1;

debug("$nwx/$nwy");

# assuming 32x24 map, Quest for Dorinthia 2 and others have bigger maps

# y pixels: 0-399 used, x pixels 20-619 used (600x400)
# tile geometry: 12x8 (50x50 per tile)

for $y (1..24) {
  for $x (1..32) {
    xdotoolkey("Return",$win);
    # go to mouse mode to avoid white square
    xdotoolkey("Tab",$win);
    # hide mouse (upper left corner is safe because there's a 20px border)
    system("xdotool mousemove $nwx $nwy");
    # capture, convert to PNG and resize as 6 google 256x256 tiles
    system("xwd -id $win | convert -crop 600x400+20+0 -geometry 768x512 - $x-$y.png");
    # back to white square mode
    xdotoolkey("Tab",$win);
    # back to main map
    xdotoolkey("Escape",$win);
    xdotoolkey("Right",$win);
  }

  die "TESTING";

}

die "TESTING";

# not sure why freedinkedit doesn't work with "xdotool key", but
# "holding" key down for a fraction of a second seems to work

# this is really really really ugly and may break so not adding it to bclib.pl

sub xdotoolkey {
  my($key,$win) = @_;
  # using system sleep (not Perl sleep) for hopefully more consistency
  # the sleep post-keyup so next xdotool command is delayed
  system("xdotool keydown --window $win $key; sleep 0.05; xdotool keyup --window $win $key; sleep 0.25");
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


