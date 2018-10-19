#!/bin/perl

# attempts to read the GAIA DR 2 files w/ aim of finding coordinates
# using parallaxes, galactic coordinates l and b

require "/usr/local/lib/bclib.pl";

my(@headers) = split(/\,/, <>);

while (<>) {

  # TODO: this is really really inefficient, but may still be fast enough

  chomp;

  my(@fields) = split(/\,/, $_);

  debug("START");
  my(%hash);
  for ($i=0; $i<=$#headers; $i++) {
    $hash{$headers[$i]} = $fields[$i];
    debug("$headers[$i] -> $fields[$i]");
  }
  debug("END");

  debug($hash{parallax});
  
  # this field is redundant (but useful)!
  if ($hash{parallax_over_error} > 1) {
    
    my($r) = 1000/$hash{parallax};
    my($x, $y, $z)=sph2xyz($hash{l}, $hash{b}, $r, "degrees=1");

    my($abs) = 5 + $hash{phot_g_mean_mag} - 5*log($r)/log(10);

    print "$hash{source_id} $x $y $z $abs\n";


#    print "$hash{parallax} $hash{l} $hash{b} $hash{phot_g_mean_mag} $hash{ra} $hash{dec}\n";
#    debug(var_dump("hash", \%hash));
  }
}

=item comment

solution_id Solution Identifier

phot_g_mean_mag phot_bp_mean_mag phot_rp_mean_mag

https://gea.esac.esa.int/archive/documentation/GDR1/Catalogue_consolidation/sec_cu1cva/sec_cu9gat.html#SS3

only mentions phot_g_mean_mag so using that as filter

parallax is in mas (milliarcseconds) per above

l and b are given (galactic long/lat!)

l = longitude, b = latitude

\ls | fgrep GaiaSource | perl -nle 'print "zcat $_ | bc-rd-gaia.pl > $_.dist"' >! dist.sh

=cut
