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

my(@beg) = @{$data{501}{"T+"}};
my(@end) = @{$data{501}{"T-"}};

my($max) = 0;
my($min) = +Infinity;
my($tot) = 0;
my($count) = 0;

for $i (0..$#beg) {

    my($time) = $end[$i] - $beg[$i];

    if ($time < 0) {die "NEGTIME";}

    $tot += $time;
    $count++;

    $min = min($min, $time);
    $max = max($max, $time);

}

debug("$min, $max, $tot, $count");


