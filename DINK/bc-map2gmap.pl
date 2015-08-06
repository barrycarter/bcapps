#!/bin/perl

# Given a directory with the output of bc-dinkles.pl, and a
# (presumably matching) dink.dat file, creates slippy-style tiles
# (which leaflet can use to create google-style maps)

# TODO: sometimes creates maps in "wrong" directory?

# slippy tile order is z,x,y
require "/usr/local/lib/bclib.pl";

my($dir,$dinkdat) = @ARGV;
unless ($dir && $dinkdat) {die "Usage: $0 directory /path/to/dink.dat";}

# TODO: shortcut unzooming when all tiles are black/blank (ie, the
# supertile is itself a link to the blank tile?)

# TODO: this program creates many symlinks and some of my mirror
# programs treat symlinks as hard files.... probably need to worry
# about that, although the blank jpg file appears to be only 417b

# <h>TONOTDO: be annoyed at how I wrote loop but never do anything about it</h>
# TODO: when calling below, check that blank.jpg actually exists
for $i (6,5,4,3,2,1,0) {slippy_unzoom($i,$dir);}
die "TESTING";

# TODO: can no longer print commands for all zoom levels in advance

my($all) = read_file($dinkdat);

# first 24 chars are garbage
$all=~s/^.{24}//s;

for $y (1..24) {
  for $x (1..32) {
    $all=~s/^(....)//s;
    my($num) = $1;
    # TODO: this breaks for >256 maps, being too lazy
#    $num = ord(substr($num,0,1));
    $num = unpack("s2",$num);
    debug("NUM: $num");
    #  tile #0 means no map in that space, do nothing
    if ($num==0) {next;}
    debug("XYN: $x,$y,$num");

    # break into 6 tiles and resize
    for $px (0,200,400) {
      for $py (0,200) {
	# x and y coords of tiles
	# TODO: MAYBE center these a bit more
	my($xc,$yc) = ($x*3+$px/200-3,$y*2+$py/200-2);
	my($outfile) = "7,$xc,$yc.jpg";
	debug("CREATING: $outfile");
	if (-f "$dir/$outfile") {next;}
	my($out,$err,$res) = cache_command2("convert $dir/temp-screen$num.jpg -crop 200x200+$px+$py -geometry 256x256 $dir/$outfile");
	debug("ERR: $err");
      }
    }
  }
}

# create level n slippy tiles (from level n+1 tiles, which must already exist)

# TODO: this is dink specific and only creates the necessary tiles,
# not all possibly level n tiles

sub slippy_unzoom {
  # $dir = directory with the level n+1 slippy tiles
  my($n,$dir) = @_;
  my($z) = $n+1;

  for $x (0..2**$n-1) {
    for $y (0..2**$n-1) {
      my(@tiles,$blanks);
      for $ns (0..1) {
	for $we (0..1) {
	  my($tilefile) = "$dir/".join(",",$z,2*$x+$we,2*$y+$ns).".jpg";
	  if (-f $tilefile) {
	    push(@tiles,$tilefile);
	  } else {
	    # doesn't exist? make a note (in case all 4 dont exist)
	    push(@tiles,"blank.jpg");
	    $blanks++;
	  }
	}
      }

      # ignore all blanks (program on server will replace with blank.jpg)
      if ($blanks==4) {next;}
      if (-f "$n,$x,$y.jpg") {next;}
      my($cmd) = "montage -geometry 128x128+0+0 ".join(" ",@tiles)." -tile 2x2 $n,$x,$y.jpg";
      system($cmd);
    }
  }
}
