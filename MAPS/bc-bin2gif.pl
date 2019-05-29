#!/bin/perl

# Given a binary file, create a fly script (?gif?) that represents
# that data, provided a width is given; assume each byte is a
# different color (TODO: allow for 2 byte combos?)

# --width: required option, how many pixels constitute a row

# TODO: maybe don't assume file can be slupred into memory

require "/usr/local/lib/bclib.pl";

my($data, $fname) = cmdfile();

unless ($globopts{width}) {die ("--width required");}

# this is probably ugly

my(@data) = split(//, $data);

# figure out image size from length

my($height) = ceil(length($data)/$globopts{width});

my(%color);

# the headers

print << "MARK";
new
size $globopts{width},$height
setpixel 0,0,0,0,0
MARK
;

# there are other ways to do this

for $row (0..$height-1) {
  for $col (0..$globopts{width}-1) {

    my($char) = shift(@data);

    # assign a color if we don't already have one
    # TODO: could theoretically get dupes

    unless ($color{$char}) {
      $color{$char} = join(",", floor(rand()*256), floor(rand()*256), floor(rand()*256));
    }

    print "setpixel $col,$row,$color{$char}\n";
  }
}
