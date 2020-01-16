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

for $moon (501..504) {
    for $type ("P", "T", "CP", "CT") {

	my(@beg) = @{$data{$moon}{"$type+"}};
	my(@end) = @{$data{$moon}{"$type-"}};

	my(@lengths);
	my($tot);

	for $i (0..$#beg) {

	    my($time) = $end[$i] - $beg[$i];
	    if ($time < 0) {die "NEGTIME";}

	    if ($time > 1000000) {die "BADTIME: $i, $end[$i], $beg[$i]";}

	    push(@lengths, $time);
	    $tot += $time;
	}

	my($max) = max(@lengths);
	my($min) = min(@lengths);
	my($mean) = $tot/($#beg + 1);

	print "$moon $type $min $mean $max $#beg+1 $#end+1\n";
	print "$lengths[0], $lengths[-1]\n";
    }
}
