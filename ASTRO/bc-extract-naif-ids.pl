#!/bin/perl

# extract NAIF ids from multiple sources creating file mapping names
# to NAIF ids, not necessarily 1 to 1 (due to errors and renamings)

# all objects in SPICE have a NAIF id, the question is:
#   - do they have a name (incl provisional names or multiple names)
#   - can we find their radius

# Data sources:

# brief -t *.bsp (but individually)
# commnt -r *.bsp (individually)
# naif_ids.html

# After running this program, do the following for join:

# join -t, -1 2 -2 1 /tmp/all-naif-ids.txt /tmp/obj-rads.txt 

require "/usr/local/lib/bclib.pl";

chdir("$bclib{githome}/ASTRO/");
my($spath) = "/home/user/SPICE/SPICE64/cspice/exe/";

# hashes:

# $id2name{id}{name}

# hasradii{x} means that we have SPICE official radii for NAIF ID

my(%id2name, %name2id, %name2rad, %hasradii);

&existing_spice_radii();
&extract_lunar_radii();

my($naifids) = read_file("naif_ids.html");

while ($naifids=~s%<pre>\s*NAIF ID\s*NAME\s*(.*?)</pre>%%s) {

    my($chunk) = $1;

    for $i (split(/\n/, $chunk)) {

	# ignore blank lines silently
	if ($i=~/^[_\s]*$/) {next;}

	# lines that have NAIF ID
	if ($i=~/^\s*(\-?\d+)\s*\'(.*?)\'/) {
#	    print A uc("$1,$2\n");
	    next;
	}
	debug("IGNORING: $i");
    }
}

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
#	    print A uc("$2,$1\n");
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
#	    print A uc("$1,$2\n");
	} elsif ($j=~/^[\s\-]*$/) {
	    # ignore blank line silently
	} else {
	    debug("IGNORING (BRF): $j");
	}
    }
}

# NOTE: only a function for convenience, not a real function

sub extract_lunar_radii {

    # look at HTML files like https://nssdc.gsfc.nasa.gov/planetary/factsheet/joviansatfact.html

    for $i (glob "SPICEMETA/*moons.html") {

	# read data for each planets moons
	my($mdata) = read_file($i);

	# look for first table (which has radii)
	
	unless ($mdata=~s%<table.*?>(.*?)</table>%%s) {
	    warn "NO TABLE IN: $i";
	    next;
	}

	my($tabdata) = $1;

	# go through table one row at a time (useful rows only)

	while ($tabdata=~s%<tr>(.*?)</tr>%%is) {

	    my($row) = $1;

	    unless ($row=~s%\s*<th>(.*?)</th>\s*<td>.*?</td>\s*<td>(.*?)</td>%%) {
		warn "IGNORING ROW: $row";
		next;
	    }


	    # extract name and radius
	    my($name, $rad) = ($1, $2);

	    # get rid of HTML spaces, parentheses, regular spaces
	    $name=~s/\&nbsp\;//g;
	    $name=~s/\(.*?\)//g;
	    $name=~s/^\s*//g;
	    $name=~s/\s*$//g;
	    $name = uc($name);

	    $name2rad{$name}{$rad} = 1;

	    # fix S/2000 J11 -> S2000_J11 and similar
	    $name=~s%S/(\d{4})\s+(.*)%S$1_$2%;

	    $name2rad{$name}{$rad} = 1;

	}
    }
}

sub existing_spice_radii {

    my($data) = read_file("/home/user/SPICE/KERNELS/pck00010.tpc");
    my($indata) = 0;

    for $i (split(/\n/, $data)) {

	if ($i=~/^\s*\\begindata\s*$/) {
	    $indata = 1;
	    next;
	}

	if ($i=~/^\s*\\begintext\s*$/) {
	    $indata = 0;
	    next;
	}

	unless ($indata) {next;}

	unless ($i=~/BODY(\d+)_RADII/i) {next;}

	$hasradii{$1} = 1;
    }
}

    

    
