#!/bin/perl

# figure out which services are down (using montastic API + multiple
# accounts) and "report" these to ~/ERR which ultimately prints to my
# background image

require "bclib.pl";

dodie('chdir("/var/tmp/montastic")');

# format of this file, each line is "username:password", # starts comments

# this is ugly (it started out as a oneliner)
# system(qq%egrep -v '^#' ~/montastic.txt | perl -nle '\$x=\$_; s/:.*//; print "curl -o \$_ -H \47Accept: application/xml\47 -u \$x https://www.montastic.com/checkpoints/index"' | parallel%);

