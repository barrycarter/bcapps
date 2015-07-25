#!/bin/perl

# Given a directory with the output of bc-dinkles.pl, and a
# (presumably matching) dink.dat file, creates slippy-style tiles
# (which bc-image-from-tiles.pl can overlay on google maps)

# slippy tile order is z,x,y
require "/usr/local/lib/bclib.pl";

my($dir,$dinkdat) = @ARGV;
unless ($dir && $dinkdat) {die "Usage: $0 directory /path/to/dink.dat";}

# TODO: currently, this just prints commands, doesn't run them

# TODO: shortcut unzooming when all tiles are black/blank (ie, the
# supertile is itself a link to the blank tile?)

# TODO: this program creates many symlinks and some of my mirror
# programs treat symlinks as hard files.... probably need to worry
# about that, although the blank jpg file appears to be only 417b

# <h>TONOTDO: be annoyed at how I wrote loop but never do anything about it</h>
for $i (6,5,4,3,2,1,0) {slippy_unzoom($i);}
die "TESTING";

my($all) = read_file($dinkdat);
# first 20 chars are garbage
$all=~s/^.{20}//s;

# for unzooming to work properly, we must create a map whose
# dimensions are powers of 2 (and possibly need to be equal); each x
# screen produces 3 gmap tiles, for a total of 96; each y screen
# produces 2 gmap tiles, total of 48; the loop counts below are higher
# to make this 128 x and 64 y

for $y (1..24) {
  for $x (1..32) {
    $all=~s/^(....)//s;
    my($num) = $1;
    # TODO: this breaks for >256 maps, being too lazy
    $num = ord(substr($num,0,1));
    # break into 6 tiles and resize
    for $px (0,200,400) {
      for $py (0,200) {
	# x and y coords of tiles
	# TODO: MAYBE center these a bit more
	my($xc,$yc) = ($x*3+$px/200-3,$y*2+$py/200-2);
	my($outfile) = "7,$xc,$yc.jpg";
	if (-f "$dir/$outfile") {next;}

	# for tile #0, symlink (don't copy) to blank.jpg (which must exist)
	if ($num==0) {system("ln -s $dir/blank.jpg $dir/$outfile");next;}

	# TODO: temp-screen0.png must exist and will be used for empty spaces
	# probably more efficient to use symlinks for temp-screen0.png
	my($out,$err,$res) = cache_command2("convert $dir/temp-screen$num.png -crop 200x200+$px+$py -geometry 256x256 $dir/$outfile");
      }
    }
  }
}

# the above will create x tiles 0-95, y tiles 0-47; below for test

for $yc (48..127) {
  for $xc (0..127) {
    system("ln -s $dir/blank.jpg $dir/7,$xc,$yc.jpg");
  }
}

for $xc (96..127) {
  for $yc (0..47) {
    system("ln -s $dir/blank.jpg $dir/7,$xc,$yc.jpg");
  }
}

# TODO: fill in remainder of 128x128 grid here

# create level n slippy tiles (from level n+1 tiles, which must already exist)

# TODO: this is dink specific and only creates the necessary tiles,
# not all possibly level n tiles

sub slippy_unzoom {
  # $dir = directory with the level n+1 slippy tiles
  my($n,$dir) = @_;

  for $x (0..2**$n-1) {
    for $y (0..2**$n-1) {
      my(@tiles);
      # which tiles to combine
      my($z) = $n+1;
      for $ty (2*$x,2*$x+1) {
	for $tx (2*$y,2*$y+1) {
	  push(@tiles, "'$z,$tx,$ty.jpg'");
	}
      }
      # TODO: figure out why this y,x not x,y
      my($cmd) = "montage -geometry 128x128+0+0 ".join(" ",@tiles)." -tile 2x2 $n,$y,$x.jpg";
      print "$cmd\n";
    }
  }
}
