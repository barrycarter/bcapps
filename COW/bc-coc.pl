#!/bin/perl

# attempts to find each countries center of population per
# https://opendata.stackexchange.com/questions/15731/how-to-find-the-country-with-the-northernmost-population
# (but I may use a different method)

# assumed input is zcat allCountries.zip | ...

# TODO: use latest geonames

require "/usr/local/lib/bclib.pl";

# load dependent data from dependentcountries_territories.csv

my(%conversions, %countrydata);

for $i (split(/\n/, read_file("$bclib{githome}/COW/dependentcountries_territories.csv"))) {

  my($iso, $name, $admin0) = csv($i);

  $conversions{$iso} = $admin0;

}

my(%totals);

while (<>) {

  # this just tests how fast it COULD go
  # about 24s on my machine, so not fast
#  next;

  my($geonameid, $name, $asciiname, $alternatenames, $latitude, $longitude,
   $featureclass, $featurecode, $admin0, $cc2, $admin1,
   $admin2, $admin3, $admin4, $population, $elevation,
   $gtopo30, $timezone, $modificationdate) = split("\t",$_);

  # if this is a PCLI, we have country data

  if ($featurecode eq "PCLI") {
    $country{$admin0}{total} = $population;
    $country{$admin0}{name} = $asciiname;
    next;
  }

  # convert admin0 if needed

  if ($conversions{$admin0}) {$admin0 = $conversions{$admin0};}

  # if population is 0 ignore

  if ($population == 0) {next;}

  # only populated places count

  unless ($featurecode=~/^PPL/) {
    debug("Non PPL population: $population ($featurecode) $name");
    next;
  }

#  unless ($featurecode eq "ADM2") {
#    next;
#  }

  

  # taking the 3D average of the where the population is which will
  # always be below the Earth's surface (since the Earth is spherical
  # and thus everywhere convext); the amount below the surface will
  # reflect how "spread out" the population is

  # TODO: consider also calculation simple average (but longitude issue)

  # TODO: compare my answers to wikipedia where it has this data

  my($x, $y, $z) = sph2xyz($longitude, $latitude, 1, "degrees=1");

  # keep track of the x/y/z total and the total population

  $totals{$admin0}{x} += $x*$population;
  $totals{$admin0}{y} += $y*$population;
  $totals{$admin0}{z} += $z*$population;
  $totals{$admin0}{population} += $population;
}

for $i (keys %totals) {

  debug("I: $i");

  my(@res) = xyz2sph(
		     $totals{$i}->{x}/$totals{$i}->{population},
		     $totals{$i}->{y}/$totals{$i}->{population},
		     $totals{$i}->{z}/$totals{$i}->{population},
		     "degrees=1");

  # longitude range -180 to 180
  if ($res[0] > 180) {$res[0] -= 360;}

  print "$i,$res[0],$res[1],$res[2],$totals{$i}->{population},$country{$i}{total},", $totals{$i}->{population}/$country{$i}{total}, ",$country{$i}{name}\n";

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

