#!/bin/perl

# attempts to find each countries center of population per
# https://opendata.stackexchange.com/questions/15731/how-to-find-the-country-with-the-northernmost-population
# (but I may use a different method)

# assumed input is zcat allCountries.zip | ...

require "/usr/local/lib/bclib.pl";

my(%totals);

while (<>) {

  my($geonameid, $name, $asciiname, $alternatenames, $latitude, $longitude,
   $featureclass, $featurecode, $admin0, $cc2, $admin1,
   $admin2, $admin3, $admin4, $population, $elevation,
   $gtopo30, $timezone, $modificationdate) = split("\t",$_);

  # if population is 0 ignore

  if ($population == 0) {next;}

  unless ($featurecode=~/^PPL/) {next;}



  debug($admin0);

}

=item comments

Used this Perl to determine which featurecodes are considered "cities":

zcat cities1000.zip | perl -F'\t' -anle 'print $F[7]' | sort | uniq -c | sort -nr

  73421 PPL
  28103 PPLA3
  20445 PPLA2
   4791 PPLX
   3831 PPLA4
   3534 PPLA
    255 PPLL
    241 PPLC
     19 PPLQ
     17 PPLG
     16 PPLA5
     15 PPLS
     11 PPLF
     10 PPLH
      4 PPLW
      3 PPLR
      1 STLMT

(ignoring STLMT, PPL is key)

=cut

