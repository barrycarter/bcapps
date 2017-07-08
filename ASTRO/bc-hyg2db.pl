#!/bin/perl

# third time's a charm? Using the HYG db at
# https://github.com/astronexus/HYG-Database/blob/master/README.md
# which actually seems to be what I need

# --equator: use equatorial coordinates (trivial, but need it for
# bc-map-equator.pl)

require "/usr/local/lib/bclib.pl";

open(A,"zcat $bclib{githome}/ASTRO/hygdata_v3.csv.gz|");

my(@head) = split(/,/,<A>);

# ignore sun
<A>;

while (<A>) {
  %hash = ();
  my(@vals) = split(/,/,$_);

  for $i (0..$#head) {$hash{$head[$i]} = $vals[$i];};

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


