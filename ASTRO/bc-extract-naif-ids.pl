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

    my($cmt) = read_file("SPICEMETA/$fname.cmt");

    unless ($cmt=~/bodies on the file:(.*?)additional constants on the file/is) {
	warn("BAD CMT FILE: $fname");
	next;
    }

    debug("GOT: $1");

}
