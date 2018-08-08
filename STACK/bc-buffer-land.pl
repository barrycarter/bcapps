#!/bin/perl

# for some reason, Mathematica is having trouble with the signed
# distance-from-coast file from
# https://oceancolor.gsfc.nasa.gov/docs/distfromcoast/, so I am
# writing a Perl program to solve
# https://earthscience.stackexchange.com/questions/14656/how-to-calculate-boundary-around-all-land-on-earth
# instead

require "/usr/local/lib/bclib.pl";

open(A, "bzcat /home/barrycarter/20180807/dist2coast.signed.txt.bz2|");

while (<A>) {
  debug("GOT: $_");
}

