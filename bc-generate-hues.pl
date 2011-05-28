#!/bin/perl

# Generates 768 32x32 images that are mostly transparent, but contain
# one dot (each image = one of 768 hues); plan to use these w/ Google
# Maps as 1 pixel icons

# Unfortunately, google does NOT accept data: URIs for marker icons
# (that would be way more efficient)

require "bclib.pl";
chdir("/home/barrycarter/BCGIT/images");

# RGB components as hue increases: \_/ /\_ _/\

for $i ("000".."768") {
  # RGB components
  if ($i<=255) {
    ($r,$g,$b) = (255-$i, $i, 0);
  } elsif ($i<=511) {
    ($r,$g,$b) = (0, 511-$i, $i-256);
  } else {
    ($r,$g,$b) = ($i-512, 0, 767-$i);
  }

  # TODO: this is actually off by 1/2 pixel, but OK?
  $flystring = << "MARK";
new
size 32,32
setpixel 0,0,255,255,255
setpixel 16,31,$r,$g,$b
MARK
;

  write_file($flystring, "temp.fly");
  system("fly -i temp.fly | convert -transparent white gif:- hue$i.png");

  # and let's generate a 1 pixel file for the hue for no good reason
  $flystring = << "MARK";
new
size 1,1
setpixel 1,1,$r,$g,$b
MARK
;

  write_file($flystring, "temp.fly");
  system("fly -i temp.fly | convert -transparent white gif:- dot$i.png");

}


