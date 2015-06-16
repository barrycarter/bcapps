#!/bin/perl

# A more direct attempt at creating maps for Dink D-Mods

require "/usr/local/lib/bclib.pl";

open(A,"map.dat")||die;
my($buf);
# 9th screen for testing
seek(A,31280*9,SEEK_SET);
read(A,$buf,31820);

dink_render_screen($buf);

# Given the 31820 byte chunk representing a screen, attempt to recreate screen in given filename

sub dink_render_screen {
  my($data,$file) = @_;

  # need better output convention
  local(*A);
  open(A,"|montage \@- -tile 12x8 -geometry +0+0 /tmp/final.png");

  # the tiles
  for $y (1..8) {
    for $x (1..12) {
      $data=~s/^.{20}(.)(.)(.{58})//s;
      # tile number and screen number (wraparound if $t>=128)
      my($t,$s) = (ord($1),2*ord($2)+1);
      if ($t>=128) {$s++; $t=-128;}
      # top left pixel
      my($px,$py) = ($t%12*50,int($t/12)*50);
      # TODO: fix tsld case oddnesses
      # create if not already existing
      unless (-f "/var/cache/DINK/tile-$s-$px-$py.png") {
	my($fname) = sprintf("/usr/share/dink/dink/Tiles/Ts%02d.bmp",$s);
	my($out,$err,$res) = cache_command2("convert -crop 50x50+$px+$py $fname /var/cache/DINK/tile-$s-$px-$py.png");
      }
      print A "/var/cache/DINK/tile-$s-$px-$py.png\n";
    }
  }
}
