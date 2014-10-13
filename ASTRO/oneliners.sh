#!/bin/sh

# list of north pole coords from north-pole-from-geocenter.txt.bz2
bzfgrep 'E+' north-pole-from-geocenter.txt.bz2 | perl -anle 'map(s/E/*10^/g, @F); print "{",join(", ",@F),"},"; sub BEGIN {print "list={";}; sub END {print "{}}; list = Drop[list,-1]"}' > /tmp/math.m

# given a saved HORIZONS page, find the data and x coordinate (only
# for Albuquerque/geocenter stuff right now)


