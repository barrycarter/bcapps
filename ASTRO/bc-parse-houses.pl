#!/bin/perl

require "/usr/local/lib/bclib.pl";

$header = <<"BARRY";
# Author: Barry Carter (astronomer\@barrycarter.info)
#
# This file is one of many that together list all
# astrological (not astronomical) constellation changes for
# Mercury, Venus, Mars, Jupiter, Saturn, and the Sun and Moon.
#
# More information at:
#
# https://github.com/barrycarter/bcapps/tree/master/ASTRO/bc-zodiac.c
#
# https://github.com/barrycarter/bcapps/tree/master/ASTRO/
#
# http://astronomy.stackexchange.com/questions/19301/period-of-unique-horosco
#
BARRY
    ;


# debug($header);

open(A, "bzcat $bclib{githome}/ASTRO/houses.txt.bz2|");

my($curfile);

while (<A>) {

    s%\s+\S+\s+\S+\s*$%%;
    
    unless (/(pro|retro)grade$/i) {warn "BAD LINE: $_";}

    unless (m%^(\S+)\s+(\d+)%) {warn "BAD LINE: $_"; next;}

    $_ .= "\n";

    my($era, $year) = ($1, $2);

    if ($era eq "BCE") {$year *= -1;}

    my($syear) = 100*floor($year/100);
    my($eyear) = $syear + 99;
    my($fname);
    
    # special case(s) to avoid small files

#    if ($syear == -13300) {$syear += 100;}

    my($era);

    if ($syear < 0) {
	$syear = abs($syear);
	$eyear = abs($eyear);
	$fname = "bce-$syear-to-bce-$eyear.txt";
	$era = "BC";
    } else {
	$fname = "ce-$syear-to-ce-$eyear.txt";
	$era = "AD";
    }

    if ($curfile eq $fname) {print B $_; next;}

    debug("NEW FILENAME: $fname");

    my($listItem) = "$syear $era to $eyear $era";

    print STDOUT qq%<li><a href="$fname" target="_blank">$listItem</a></li><p />\n%;

    # current file is not equal to fname
    close(B);
    $curfile = $fname;
    open(B, ">/home/user/BCGIT-PAGES/pages/DATA/HOUSES/$fname");
    print B $header;
    print B $_;
#    debug("FNAME: $fname, $year");
#    debug("GOT: $_");

}


