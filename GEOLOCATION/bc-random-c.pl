#!/bin/perl

# Generates random addresses in EVERY "class C" network, with the
# intent of hitting every major ISP; of course, we now use CIDR, so
# "class C" is meaningless

push(@INC,"/usr/local/lib");
require "bclib.pl";

@l = (0..256**3);
@l = randomize(\@l);
