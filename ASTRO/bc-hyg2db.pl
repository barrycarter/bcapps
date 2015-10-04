#!/bin/perl

# third time's a charm? Using the HYG db at
# https://github.com/astronexus/HYG-Database/blob/master/README.md
# which actually seems to be what I need

require "/usr/local/lib/bclib.pl";

# testing

my(@mat) = rotrad(23.443683*$DEGRAD,"x");

my(@star) = sph2xyz(0,0,1);

debug("STAR",@star);

my(@res) = matrixmult(\@mat,[[$star[0]],[$star[1]],[$star[2]]]);

debug("RES",unfold(@res));




