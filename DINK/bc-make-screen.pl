#!/bin/perl

# command that is called to create a dink screen from modified dinkvar.c

require "/usr/local/lib/bclib.pl";

my($screen,$path) = @ARGV;

open(A,">$path");

# the tiles

for $y (1..8) {
  for $x (1..12) {
    # 20 character tile name (ignored)
#    print A "barry carter is here";
    print A "\0"x20;

    # for now, repeat the same tile
    # may end up doing this long term if we use background BMPs + alt hardness?
    print A "\000\000";
    # the other 58 chars that make up a tile
    print A "\000"x58;
  }
}

# this is overkill but fills the required 31280 bytes
print A "\000"x312800;

close(A);
