#!/bin/perl

# Given a directory with the output of bc-dinkles.pl, and a
# (presumably matching) dink.dat file, creates slippy-style tiles
# (which bc-image-from-tiles.pl can overlay on google maps)

# slippy tile order is z,x,y
require "/usr/local/lib/bclib.pl";

my($dir,$dinkdat) = @ARGV;
unless ($dir && $dinkdat) {die "Usage: $0 directory /path/to/dink.dat";}

my($all) = read_file($dinkdat);
# first 20 chars are garbage
$all=~s/^.{20}//s;

for $y (1..24) {
  for $x (1..32) {
    $all=~s/^(....)//s;
    my($num) = $1;
    # TODO: this breaks for >256 maps, being too lazy
    $num = ord(substr($num,0,1));
    if ($num==0) {next;}
    # break into 6 tiles and resize
    for $px (0,200,400) {
      for $py (0,200) {
	# x and y coords of tiles
	# TODO: MAYBE center these a bit more
	my($xc,$yc) = ($x*3+$px/200-1,$y*2+$py/200-1);
	my($outfile) = "7,$xc,$yc.jpg";
	my($out,$err,$res) = cache_command2("convert $dir/temp-screen$num.png -crop 200x200+$px+$py -geometry 256x256 $dir/$outfile");
      }
    }
  }
}


die "TESTING";

# TODO: don't hardcode
my($screendir) = "/usr/local/etc/DINK/MAPS/solstice";
# TODO: in general, don't keep images in git, unnecessary/wasteful
# this is where I keep things I don't need in git but do need on bcinfo3
my($targetdir) = "/home/barrycarter/BCINFO3-PRIV/sites/MAP/IMAGES/TEST/";

for $y (1..24) {
  for $x (1..32) {

    # TODO: create "blank" map as we will need this
    if ($maps{$x}{$y} == 0) {next;}

    # screen x,y creates 7,x,y (for future expansion purposes)
    # TODO: better naming convention
    unless (-f "$targetdir/5,$x,$y.png") {
      system("cp $screendir/temp-screen$maps{$x}{$y}.png $targetdir/5,$x,$y.png");
    }
  }
}

