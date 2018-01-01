#!/bin/perl

# inspired by https://astronomy.stackexchange.com/questions/24276/if-we-could-travel-far-enough-would-we-be-able-to-see-a-constelation-in-reverse, plots a trip to Orion using HYG

# 1951 stars in Orion but also 1629 with no constellation listed

=item disclaimers

HYG not all stars (GAIA/NOMAD = no distances)

only 1% of all stars known

approaching galactic center = faint/unknown stars much brighter

ignoring 1629 stars w/ no const listed(?), mags are 12.01 to 21.00

orion boundary (bounding box): 6.5h to 4.75h (very roughly) and -11 to +23

http://www.astronexus.com/hyg caveats also apply

precession!

proper motion?

if using js3d or whatever, size increases as square, perhaps not ideal?

=cut

=item notes


head dir is 0 dec, 5.5h ra or 82.5 deg so is {sin(82.5), cos(82.5), 0}

TODO: 0 z is orion specific grumble

TODO: fix my glib NOMAD comment for "I want db w/ distances"


=cut

require "/usr/local/lib/bclib.pl";

open(A,"zcat $bclib{githome}/ASTRO/hygdata_v3.csv.gz|");

my(@head) = split(/,/,<A>);

# ignore sun
<A>;

while (<A>) {
  %hash = ();
  my(@vals) = split(/,/,$_);

  for $i (0..$#head) {$hash{$head[$i]} = $vals[$i];};

  unless ($hash{con} eq "Ori" || $hash{con}=~/^\s*$/) {next;}

  unless ($hash{con}=~/^\s*$/) {next;}

  # TODO: worry about stars in no constellation
  debug("$hash{con} $hash{mag} $hash{ra} $hash{dec}");
  

#  debug("HASH",%hash);

#  debug("CON: $hash{con}");

  next;

  warn "TESTING"; next;





  # 0 as placeholder for NA
  unless ($hash{hip}) {$hash{hip}=0;}

  # need hip, ra, dec, mag

  # ignore dim stars
  if ($hash{mag}>6.5) {next;}

  debug("RA: $hash{ra}, DEC: $hash{dec}");


  # convert to ecliptic coords
  my($elon,$elat) = equ2ecl($hash{ra}*$PI/12,$hash{dec}*$DEGRAD);
  map($_=$_*180/$PI,($elon,$elat));

  # ignore further than 15deg away
#  if (abs($elat)>15) {next;}

  if ($globopts{equator}) {
    printf("%f %f $hash{mag} $hash{hip} $hash{proper}\n", $hash{ra}*15, $hash{dec});
  } else {
    # output is: elon elat mag hip# name (optional)
    print "$elon $elat $hash{mag} $hash{hip} $hash{proper}\n";
  }
}

=item equ2ecl($ra,$dec)

Given right ascension and declination (radians), return ecliptic
coordinates (in radians), assuming J2000

=cut

sub equ2ecl {
  my($ra,$dec) = @_;

  # TODO: recomputing this each time is ugly
  my(@mat) = rotrad(23.443683*$DEGRAD,"x");

  # to xyz
  my($x,$y,$z) = sph2xyz($ra,$dec,1);

  # matrix multiplication
  # TODO: this is ugly, make matrix dot vector easier?
  my(@xyz2) = matrixmult(\@mat,[[$x],[$y],[$z]]);

  return xyz2sph($xyz2[0][0],$xyz2[1][0],$xyz2[2][0]);
}


