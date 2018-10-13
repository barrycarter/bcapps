#!/bin/perl

# attempts to read the GAIA DR 2 files w/ aim of finding coordinates
# using parallaxes, RA, and DEC

require "/usr/local/lib/bclib.pl";

my(@headers) = split(/\,/, <>);

while (<>) {

  chomp;

  my(@fields) = split(/\,/, $_);

  my(%hash);
  for ($i=0; $i<=$#headers; $i++) {
    $hash{$headers[$i]} = $fields[$i];
  }

#  if ($hash{phot_g_mean_mag} <= 6) {
    debug(var_dump("hash", \%hash));
#  }
  

}


=item comment

phot_g_mean_mag phot_bp_mean_mag phot_rp_mean_mag

https://gea.esac.esa.int/archive/documentation/GDR1/Catalogue_consolidation/sec_cu1cva/sec_cu9gat.html#SS3

only mentions phot_g_mean_mag so using that as filter

parallax is in mas (milliarcseconds) per above

=cut
