#!/bin/perl

# use images instead of text in fly text

require "/usr/local/lib/bclib.pl";

@ret = flystring(100,500,"hel[file:/home/barrycarter/BCGIT/ASTRO/Earth_symbol.svg.gif]lo","giant","255,0,0");

print "new\nsize 800,600\nsetpixel 0,0,255,255,255\n";
print join("\n",@ret),"\n";

# from http://tecfa.unige.ch/guides/utils/fly-use.html
# tiny (5x8), small (6x12), medium (7x13), large (8x16), giant (9x15)

die "TESTING";

print << "MARK";
new
size 800,600
setpixel 0,0,255,255,255
string 255,0,0,100,500,tiny,hello
copyresized -1,-1,-1,-1,110,510,120,520,/home/barrycarter/BCGIT/ASTRO/Earth_symbol.svg.gif
colourchange 0,0,0,255,0,0,0
MARK
;

=item flystring($x,$y,$str,$size,$color)

Generate the fly commands to place $str of size $size at $x,$y but
allow for images in strings, eg "hel[image:path-to-image]0"

=cut

sub flystring {
  my($x,$y,$str,$size,$color) = @_;
  # TODO: determine below from size
  my($w,$h) = (9,15);
  my(@ret);

  # assuming giant for now
  # handle image case first, and then text

  while ($str) {
    # image?
    if ($str=~s/^\[file:(.*?)\]//) {
      # TODO: this wrongly assumes image is black on white
      push(@ret, join(",", "copyresized -1,-1,-1,-1",$x,$y,$x+$h,$y+$h,$1));
#      push(@ret, "colourchange 0,0,0,$color");
    } else {
      $str=~s/^(.)//;
      push(@ret, "string $color,$x,$y,$size,$1");
    }

    # in either case, advance the place where I print
    $x+=$w;
  }

  return @ret;
}


