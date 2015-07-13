#!/bin/perl

# command that is called to create a dink screen from modified dinkvar.c

require "/usr/local/lib/bclib.pl";

my($screen,$path) = @ARGV;

# code to run based on screen "entered"
# direction from $screen
# my(@dir) = ("0", "north","2","south","west","east");
my(@dir) = ("", "&y += 1","","&y -= 1","&x -= 1","&x += 1");

# figure out directory, we'll need it later
my($dir) = $path;
$dir=~s%/([^/]*?)$%%;

# read save file
my(%dinkvars) = dink_read_save_dat(read_file("$dir/save0.dat"));

open(A,">$path");

# the tiles

for $y (1..8) {
  for $x (1..12) {
    # 20 character tile name (ignored)
#    print A "barry carter is here";
    print A "\0"x20;

    # for now, repeat the same tile
    # may end up doing this long term if we use background BMPs + alt hardness?
#    print A "\002\005";
    print A "\000\000";
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

# now create the script dynamically

open(A,">$dir/story/DYNAMIC.c");
print A << "MARK";
$dir[$screen];
say_stop("Coords: &x,&y,&z",1);
MARK
;

close(A);

# read variables from save file

sub dink_read_save_dat {
  my($data) = @_;
  my(%ret);

  while ($data=~s/(....)\&(.{20})//) {
    my($val,$var) = ($1,$2);
    $var=~s/\0//g;
    $val = unpack("i",$val);
    $ret{$var}=$val;
  }
  return %ret;
}
