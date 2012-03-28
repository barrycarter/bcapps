#!/bin/perl

# attempt to display "animated PNG" (really MIME multipart) that may
# one day display bandwidth speed

push(@INC, "/usr/local/lib");
require "bclib.pl";
use GD;

# avoid caching
select(STDOUT);
$|=1;

# TODO: count time to the millisecond
$t0 = time();

# MIME boundary
$boundary="---xyz---";
countprint("Content-type: multipart/x-mixed-replace;boundary=$boundary\n\n");

# the boundry for the first image
countprint("$boundary\n");

# this loop goes forever
for (;;) {
  # header for this specific image
  countprint("Content-type: image/png\n\n");

  # testing by just printing increasing numbers
  $n++;

  # create the image (following "perldoc GD" here) w/ transparent bg
  $im = new GD::Image(800,30);
  $white = $im->colorAllocate(255,255,255);
  $black = $im->colorAllocate(0,0,0);
  $im->transparent($white);

  # time so far
  $t = time()-$t0;

  # rate
  $rate = $bytes/($t||1);

  # and write my string
  $im->string(GD::gdGiantFont,0,0,"I have sent $bytes bytes in $t seconds. That's $rate bytes per second",$black);

  countprint($im->png);

  # end boundary
  countprint("\n$boundary\n");

  # safety check (for now)
  sleep(1);

}

# in theory, could end entire MIMEtype here, but since loop above is
# infinite, no need

# count bytes as I print them
sub countprint {
  my($str) = @_;
  $bytes+= length($str);
  print $str;
}
