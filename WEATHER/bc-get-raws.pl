#!/bin/perl

# obtain RAWS information (more current than KML)

require "/usr/local/lib/bclib.pl";

@res = get_raws_obs();
@queries = hashlist2sqlite(\@res, "madis");

my($daten) = `date +%Y%m%d.%H%M%S.%N`;
chomp($daten);
my($qfile) = "/var/tmp/querys/$daten-madis-get-raws-$$";
open(A,">$qfile");

print A "BEGIN;\n";

for $i (@queries) {
  # REPLACE if needed
  $i=~s/IGNORE/REPLACE/;
  print A "$i;\n";
}

print A "COMMIT;\n";
close(A);
