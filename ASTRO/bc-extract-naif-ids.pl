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

my($naifids) = read_file("naif_ids.html");

while ($naifids=~s%<pre>\s*NAIF ID\s*NAME\s*(.*?)</pre>%%s) {



}


die "TESTING";

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
	    print uc("$2,$1\n");
	} elsif ($j=~/^\s*$/) {
	    # do nothing, ignore blank line
	} else {
	    debug("IGNORING (CMT): $j");
	}
    }

    # read brief file
    my($brf) = read_file("SPICEMETA/$fname.brf");

    # find section of interest
    if ($brf=~/\s*Bodie.*?Start of Interval \(ET\)\s*End of Interval \(ET\)\s*(.*?)$/is) {
	$brf = $1;
    } else {
	warn("BAD BRF FILE: $fname");
	$brf = "";
    }

    # loop through lines
    for $j (split(/\n/, $brf)) {
	
	if ($j=~/^(\d+)\*?\s+(.*?)\*?\s{2,}/) {
	    print uc("$1,$2\n");
	} elsif ($j=~/^[\s\-]*$/) {
	    # ignore blank line silently
	} else {
	    debug("IGNORING (BRF): $j");
	}
    }
}

