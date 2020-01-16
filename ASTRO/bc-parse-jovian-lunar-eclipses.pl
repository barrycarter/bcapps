#!/bin/perl

require "/usr/local/lib/bclib.pl";

chdir("$bclib{githome}/ASTRO")||die("Can't chdir");

my(%data);

open(A, "bzcat jupiter-gallilean-eclipses.txt.bz2|");

while (<A>) {

#    if ($count++ > 10000) {warn "TESTING"; last;}

    chomp;

    my($moon, $sun, $planet, $type, $et, $sd) = split(/\s+/, $_);

    push(@{$data{$moon}{$type}}, $et);
}

debug(unfold(%data));



