#!/bin/perl

# attempt to display animated GIF that may one day display bandwidth speed
# not true animated GIF, actually using MIME multipart

require "bclib.pl";
use GD;

# MIME boundary
$boundary="---xyz---";
print "Content-type: multipart/x-mixed-replace;boundary=$boundary\n\n";

# the boundry for the first image
print "$boundary\n";

# this loop goes forever
for (;;) {
  # header for this image <h>(it's really JPEG, don't tell anyone!)</h>
