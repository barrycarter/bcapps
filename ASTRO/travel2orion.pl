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

blue shift

if using js3d or whatever, size increases as square, perhaps not ideal?

=cut

=item notes


head dir is 0 dec, 5.5h ra or 82.5 deg so is {sin(82.5), cos(82.5), 0}

TODO: 0 z is orion specific grumble

TODO: fix my glib NOMAD comment for "I want db w/ distances"

TODO: rotate to side view? (circle around orion instead of approach?)

TODO: quote Quixote?

sample star:

xyz = 51.601106, 256.709905, -37.740051

dist = 264.5503 (so xyz in parsecs)

absmag -6.933 and realmag 0.180, so

Log10[264.5503/10]*5

y is into screen

x is decreasing ra

z is increasing dec

sph coords and then leftwards rotation should suffice (of course, we
already sort of have that?)

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



  unless ($hash{con} eq "Ori") {next;}

  if ($hash{mag}<3) {
    debug("<HASH>");
    for $i (sort keys %hash) {
      debug("$i -> $hash{$i}");
    }
    debug("</HASH>");

  }
    
# debug("HASH",%hash);}



  # TODO: worry about stars in no constellation
#  debug("$hash{con} $hash{mag} $hash{ra} $hash{dec}");
  

#  debug("HASH",%hash);

#  debug("CON: $hash{con}");

  plot_star(0,0,0,0,0,0,\%hash);

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

# program specific: given your xyz position, nosecone point vector,
# and star information, determine how to plot the star

sub plot_star {

  my($x, $y, $z, $vx, $vy, $vz, $hashref) = @_;
  my(%star) = %{$hashref};

  # TODO: this is just a fixed mapping from Earth for now

  debug("GOT:",%star);

  # spherical coordinates
  my($th, $ph, $r) = xyz2sph($star{x}, $star{y}, $star{z}, "degrees=1");

  # visual magnitude
  my($vm) = 5*log($r)/log(10)-5+$star{absmag};



  debug("TH/PH/R/VM: $th, $ph, $r, $vm");

  die "TESTING";
}

=item comment

spectral class colors from http://www.vendian.org/mncharity/dir3/starcolor/

O5(V) 157 180 255 #9db4ff
B1(V) 162 185 255 #a2b9ff
B3(V) 167 188 255 #a7bcff
B5(V) 170 191 255 #aabfff
B8(V) 175 195 255 #afc3ff
A1(V) 186 204 255 #baccff
A3(V) 192 209 255 #c0d1ff
A5(V) 202 216 255 #cad8ff
F0(V) 228 232 255 #e4e8ff
F2(V) 237 238 255 #edeeff
F5(V) 251 248 255 #fbf8ff
F8(V) 255 249 249 #fff9f9
G2(V) 255 245 236 #fff5ec
G5(V) 255 244 232 #fff4e8
G8(V) 255 241 223 #fff1df
K0(V) 255 235 209 #ffebd1
K4(V) 255 215 174 #ffd7ae
K7(V) 255 198 144 #ffc690
M2(V) 255 190 127 #ffbe7f
M4(V) 255 187 123 #ffbb7b
M6(V) 255 187 123 #ffbb7b

TODO: see also http://www.isthe.com/chongo/tech/astro/HR-temp-mass-table-byhrclass.html?

=cut
