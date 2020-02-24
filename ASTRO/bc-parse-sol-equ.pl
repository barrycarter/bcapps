#!/bin/perl

require "/usr/local/lib/bclib.pl";

$header = <<"BARRY";
# Author: Barry Carter (astronomer\@barrycarter.info)
#
# This file is one of many that together list all equinoxes and solstices
# approximately +-15000 years from now. Seasons refer to northern
# hemisphere and are reversed in the southern hemisphere.
#
# All times UTC
#
# More information at:
#
# (note that code below only computes equinoxes, but similar code was used 
# to compute solstices)
#
# https://github.com/barrycarter/bcapps/tree/master/STACK/bc-solve-astro-13008.c
#
# https://github.com/barrycarter/bcapps/tree/master/ASTRO/
#
# https://astronomy.stackexchange.com/questions/13008/are-there-accurate-
#
BARRY
    ;


# goal/format is roughly something like:

# CE 1100-MAR-25 17:30 VENUS ENTERS ARIES PROGRADE

my($curfile);

open(A, "bzcat $bclib{githome}/ASTRO/solstices-and-equinoxes.txt.bz2|");

####### THIS IS CUT POINT (below this line, copy of bc-parse-houses) ######

# the first solstice and equinox in the file are winter and spring

my(@sol) = ("WINTER", "SUMMER");
my(@equ) = ("SPRING", "AUTUMN");

my($solindex) = 1;
my($equindex) = 1;

my(%eraconvert) = ("B.C." => "BCE", "A.D." => "CE");

while (<A>) {

  debug("THUNK: $_");

  my($type, $et, $era0, $date, $time) = split(/\s+/, $_);

  # get rid of seconds
  $time=~s/:\d\d//;

  # the string to print
  my($str);

  if ($type eq "SOL") {
    $str = "$eraconvert{$era0} $date $time $sol[$solindex] SOLSTICE\n";
    $solindex = 1-$solindex;
  } elsif ($type eq "EQU") {
    $str= "$eraconvert{$era0} $date $time $equ[$equindex] EQUINOX\n";
    $equindex = 1-$equindex;
  } else {
    die "IMPOSSIBLE CASE";
  }


  # find the year

  $year = $date;
  $year=~s/\-.*//g;

  if ($era0 eq "B.C.") {$year *= -1;}

  my($syear) = 100*floor($year/100);
  my($eyear) = $syear + 99;
  my($fname);
    
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

    if ($curfile eq $fname) {print B $str; next;}

    debug("NEW FILENAME: $fname");

    print STDOUT qq%<li><a href="$fname" target="_blank">$str</a></li><p />\n%;

    # current file is not equal to fname
    close(B);
    $curfile = $fname;
    open(B, ">/home/user/BCGIT-PAGES/pages/DATA/EQUSOL/$fname");
    print B $header;
    print B $str;
}



