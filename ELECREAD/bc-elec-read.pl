#!/bin/perl

# read electric meter automatically

require "/usr/local/lib/bclib.pl";

# these are roughly the 5 center points of the dials in any image

# 67,60
# 149,68
# 232,77
# 314,85
# 390,92

# general idea is to read circles radiating out from center points and
# find "darkest point" for each dial

