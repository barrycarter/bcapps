#!/bin/perl

# attempt to display "animated PNG" (really MIME multipart) that may
# one day display bandwidth speed

push(@INC, "/usr/local/lib");
require "bclib.pl";
use GD;

# avoid caching
select(STDOUT);
$|=1;

# MIME boundary
$boundary="---xyz---";
print "Content-type: multipart/x-mixed-replace;boundary=$boundary\n\n";

# the boundry for the first image
print "$boundary\n";

# this loop goes forever
for (;;) {
  # header for this specific image
  print "Content-type: image/jpeg\n\n";

  # testing by just printing increasing numbers
  $n++;

  # create the image (following "perldoc GD" here) w/ transparent bg
  $im = new GD::Image(80,30);
  $white = $im->colorAllocate(255,255,255);
  $black = $im->colorAllocate(0,0,0);
  $im->transparent($white);

  # and write my string
  $im->string(GD::gdSmallFont,0,30,$n,$black);

  print $im->jpeg;

  # end boundary
  print "\n$boundary\n";

  # safety check (for now)
  sleep(1);

}

# in theory, could end entire MIMEtype here, but since loop above is
# infinite, no need
