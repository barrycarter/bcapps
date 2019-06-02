#!/bin/perl

# Given a binary file, create a fly script (?gif?) that represents
# that data, provided a width is given; assume each byte is a
# different color (TODO: allow for 2 byte combos?)

# --width: required option, how many pixels constitute a row

# --bytesize: how many bytes constitute a data chunk (currently, '2'
# is only supported value)

# TODO: maybe don't assume file can be slupred into memory

require "/usr/local/lib/bclib.pl";

defaults("bytesize=1");

my($data, $fname) = cmdfile();

unless ($globopts{width}) {die ("--width required");}

# this is probably ugly

my(@data) = split(//, $data);

# figure out image size from length

my($height) = ceil(length($data)/$globopts{width}/$globopts{bytesize});

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

    # TODO: this is ugly

    my($char) = "";

    for $i (1..$globopts{bytesize}) {
      $char .= shift(@data);
    }

    debug("CHAR: $char");

    # assign a color if we don't already have one
    # TODO: could theoretically get dupes

    unless ($color{$char}) {
      $color{$char} = join(",", floor(rand()*256), floor(rand()*256), floor(rand()*256));
    }

    print "setpixel $col,$row,$color{$char}\n";
  }
}
