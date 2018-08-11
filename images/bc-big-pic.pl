#!/bin/perl

# attempt to see how fast fly/perl can create a large image; I've
# always assumed it's prohibitively slow to use Perl/fly to create
# large images, but maybe not

require "/usr/local/lib/bclib.pl";

# 255 random colors to start with!

my(@colors);

for $i (1..255) {
  push(@colors, join(",",floor(rand()*255), floor(rand()*255), floor(rand()*255)));
}

debug(@colors);

die "TESTING";
      

print "new\nsize 4096,4096\n";


for $i (0..4095) {
  for $j (0..4095) {
    my($r, $g, $b) = (floor(rand()*255), floor(rand()*255), floor(rand()*255));
    print "setpixel $i,$j,$r,$g,$b\n";
  }
}

# with 16384^2 random points, takes 6:32.27 (6.5m)

# with 4096^2, takes 0:23.14

# so roughly prop to #dots

# on 4096^2, fly -q itself takes: 0:17.60 [but image fails, too many colors!]

