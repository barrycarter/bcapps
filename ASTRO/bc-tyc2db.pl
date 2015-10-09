#!/bin/perl

# I'm having issues with the Hipparcos catalog (bad version/compile of
# scat?), so using the Tycho catalog and doing the equatorial to
# ecliptic translations myself (sigh)

die "This does not work + will be removed soon; use bc-hyg2db.pl instead";

require "/usr/local/lib/bclib.pl";

# downloaded as tar from http://vizier.u-strasbg.fr/viz-bin/Cat?I/259

# there are two versionf of Tycho, confirmed this one IS J2000

open(A,"zcat /home/barrycarter/SPICE/KERNELS/I259/tyc2.dat.??.gz|");

while (<A>) {

  my($pflag) = get_chars($_,14,15);
  my($ra) = get_chars($_,16,28);
  my($dec) = get_chars($_,29,41);
  my($mag) = get_chars($_,124,130);
  my($hip) = get_chars($_,143,148);

  # trim spaces
  map(s/\s//g, ($ra,$dec,$mag,$hip));

  # TODO: restore this to 6.5, lowered for testing
  # ignore faint and blank ra/dec
  if ($mag>1.5 || length($ra)==0 || length($dec)==0 || length($mag)==0) {next;}

  debug("$ra/$dec/$mag/$hip/$pflag");
}

# wrapper around substr so I can match tycho2-guide.pdf intentionally
# snips pipe character at end since I don't need it (this also means
# this subroutine, as written, is not valid for general use)

sub get_chars {
  my($str,$x,$y) = @_;
  return substr($str,$x-1,$y-$x);
}

