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
&extract_brief_ids();
&extract_commnt_ids();
&extract_html_ids();

sub extract_html_ids {

    my($naifids) = read_file("naif_ids.html");

    while ($naifids=~s%<pre>\s*NAIF ID\s*NAME\s*(.*?)</pre>%%s) {

	my($chunk) = $1;

	for $i (split(/\n/, $chunk)) {

	    # ignore blank lines silently
	    if ($i=~/^[_\s]*$/) {next;}

	    # lines that have NAIF ID
	    unless ($i=~/^\s*(\-?\d+)\s*\'(.*?)\'/) {next;}

	    $name2id{$2}{$1} .= "html";
	    $id2name{$1}{$2} .= "html";
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

sub extract_brief_ids {

    # look at all binary kernels
    for $i (glob "/home/user/SPICE/KERNELS/*.bsp") {

	# filename without path and without bsp extension
	my($fname) = $i;
	$fname=~s/^.*\///;
	$fname=~s/\.bsp$//;

	# if the brf file doesn't exist, create it
	unless (-s "SPICEMETA/$fname.brf") {
	    my($out, $err, $res) = cache_command("$spath/brief -t $i > SPICEMETA/$fname.cmt");
	}

	# read brief file
	my($brf) = read_file("SPICEMETA/$fname.brf");

	# find section of interest
	unless ($brf=~/\s*Bodie.*?Start of Interval \(ET\)\s*End of Interval \(ET\)\s*(.*?)$/is) {
	    next;
	}

	$brf = $1;


	# loop through lines
	for $j (split(/\n/, $brf)) {

	    # ignore blank line silently
	    if ($j=~/^[\s\-]*$/) {next;}
	
	    unless ($j=~/^(\d+)\*?\s+(.*?)\*?\s{2,}/) {
		warn("BAD BRF LINE: $j");
		next;
	    }

	    $name2id{$2}{$1} .= "brief";
	    $id2name{$1}{$2} .= "brief";
	}
    }
}

sub extract_commnt_ids {

    # look at all binary kernels
    for $i (glob "/home/user/SPICE/KERNELS/*.bsp") {

	# filename without path and without bsp extension
	my($fname) = $i;
	$fname=~s/^.*\///;
	$fname=~s/\.bsp$//;

	# if the cmt file doesn't exist, create it
	unless (-s "SPICEMETA/$fname.cmt") {
	    my($out, $err, $res) = cache_command("$spath/commnt -r $i > SPICEMETA/$fname.cmt");
	}

	# read comment file
	my($cmt) = read_file("SPICEMETA/$fname.cmt");

	# find section of interest

	unless ($cmt=~/Name\s+Number\s+GM\s+NDIV\s+NDEG\s+Model\s*(.*?)additional constants on the file/is) {next;}

	$cmt = $1;

	# loop through lines
	for $j (split(/\n/, $cmt)) {

	    if ($j=~/^\s*$/) {next;}

	    # does this line have a NAIF ID?
	    unless ($j=~/^\s*(.*?)\s+(\d+)\s/) {
		unless ($j=~/^\s*System\s*/) {warn("BAD CMT LINE: $j");}
		next;
	    }
		
	    my($name, $id) = ($1, $2);
	    
	    $name2id{$name}{$id} .= "comment";
	    $id2name{$id}{$name} .= "brief";
	}
    }
}
