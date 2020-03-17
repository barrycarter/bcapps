#!/bin/perl

require "/usr/local/lib/bclib.pl";

open(A, "bzcat /home/user/SPICE/KERNELS/small-body-db.csv.bz2|");

$headers = <A>;

@headers = split(/\,/, $headers);

# fields we want: spkid, full_name, diameter, extent, 

while (<A>) {

    chomp;

    my(@data) = split(/\,/, $_);
    my(%hash) = ();

    for $i (0..$#headers) {$hash{$headers[$i]} = $data[$i];}

    if ($hash{extent}) {

	unless ($hash{extent}=~/^"?\s*([\d\.]+)\s*x\s*([\d\.]+)\s*x\s*([\d\.]+)\s*"?$/) {
	    warn "BAD EXTENT: $hash{extent}";
	    next;
	}

	debug("EXTENT: $1 $2 $3");

	# radii are half of diameters
	print "BODY$hash{spkid}_RADII = (",$1/2," ",$2/2," ",$3/2,")\n";


    } elsif ($hash{diameter}) {

	# divide diameter by 2 for radii
	my($rad) = $hash{diameter}/2;

	print "BODY$hash{spkid}_RADII = ($rad $rad $rad)\n";
    } else {
	# TODO: should I worry more about this?
	debug("BADLINE: $_");
	for $i (keys %hash) {debug("BADLINE ($i) -> $hash{$i}");}
    }
}


#    for $i (sort keys %hash) {debug("$i: $hash{$i}");}

#    for $i ("spkid", "full_name", "diameter", "extent") {
#	debug("$i: $hash{$i}");
#    }






