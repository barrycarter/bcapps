#!/bin/perl

# Given output of bc-dinkles.pl, tries to figure out when each screen
# image goes using MAP.DAT

# TODO: much bigger map, this is just testing

# small image: 32 tiles wide, 24 tiles long, squashed 255x255

# slippy tile order is z,x,y

require "/usr/local/lib/bclib.pl";

# hash to map location to map
my(%maps);

# TODO: do read_file here, so I don't have to loop twice?
open(A,"dink.dat")||die("Can't open dink.dat, $!");

# first 8 bytes are header
seek(A,21,SEEK_SET);
my($buf);

# 20 bytes at a time

for $y (1..24) {
  for $x (1..32) {
    read(A,$buf,4);
    # convert to int (TODO: not just last byte)
    my($num) = ord(substr($buf,3,1));
    $maps{$x}{$y} = $num;
  }
}

close(A);

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

