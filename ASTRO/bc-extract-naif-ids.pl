#!/bin/perl

# extract NAIF ids from multiple sources creating file mapping names
# to NAIF ids, not necessarily 1 to 1 (due to errors and renamings)

# Data sources:

# brief -t *.bsp (but individually)
# commnt -r *.bsp (individually)
# naif_ids.html

require "/usr/local/lib/bclib.pl";

my($spath) = "/home/user/SPICE/SPICE64/cspice/exe/";

chdir("$bclib{githome}/ASTRO/");

for $i (glob "/home/user/SPICE/KERNELS/*.bsp") {

    # filename without path and without bsp extension
    my($fname) = $i;
    $fname=~s/^.*\///;
    $fname=~s/\.bsp$//;

    debug("KERNEL: $fname");

    # create the cmt and brf files if they don't exist

    my($out, $err, $res);

    unless (-s "SPICEMETA/$fname.cmt") {
	($out, $err, $res) = cache_command("$spath/commnt -r $i > SPICEMETA/$fname.cmt");
    }

    unless (-s "SPICEMETA/$fname.brf") {
	($out, $err, $res) = cache_command("$spath/brief -t $i > SPICEMETA/$fname.brf");
    }

    # read comment file
    my($cmt) = read_file("SPICEMETA/$fname.cmt");

    # find section of interest
    if ($cmt=~/Name\s+Number\s+GM\s+NDIV\s+NDEG\s+Model\s*(.*?)additional constants on the file/is) {
	$cmt = $1;
    } else {
	warn("BAD CMT FILE: $fname");
	$cmt = "";
    }

    # loop through lines
    for $j (split(/\n/, $cmt)) {

	# does this line have a NAIF ID?
	if ($j=~/^\s*(.*?)\s+(\d+)\s/) {
	    print "$2,$1\n";
	} elsif ($j=~/^\s*$/) {
	    # do nothing, ignore blank line
	} else {
	    debug("IGNORING: $j");
	}
    }
}

