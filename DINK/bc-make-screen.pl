#!/bin/perl

# command that is called to create a dink screen from modified dinkvar.c

require "/usr/local/lib/bclib.pl";

my($screen,$path) = @ARGV;

# direction from $screen
my(@dir) = ("0", "north","2","south","west","east");

# figure out directory, we'll need it later
my($dir) = $path;
$dir=~s%/([^/]*?)$%%;

open(A,">$path");

# unused screen name
# print A "\0"x19;

# the tiles

for $y (1..8) {
  for $x (1..12) {
    # 20 character tile name (ignored)
#    print A "barry carter is here";
    print A "\0"x20;

    # for now, repeat the same tile
    # may end up doing this long term if we use background BMPs + alt hardness?
    print A "\002\005";
    # the other 58 chars that make up a tile
    print A "\000"x58;
  }
}

# unused fields + some alignment issues?
print A "\000"x340;

# sprites (which you can also script in later); sprite 0 always empty
for $s (0..100) {print A "\000"x220;}

print A "DYNAMIC";

# fill to 31280 bytes
print A "\000"x1035;

close(A);

my($date)=`date`;
chomp($date);

# now create the script dynamically

open(A,">$dir/story/DYNAMIC.c");
print A << "MARK";
say_stop("I just walked direction $screen ($dir[$screen]) at $date",1);
MARK
;

close(A);
