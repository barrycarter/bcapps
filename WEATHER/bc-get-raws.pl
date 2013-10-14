#!/bin/perl

# obtain RAWS information (more current than KML)

require "/usr/local/lib/bclib.pl";

@res = get_raws_obs();
@queries = hashlist2sqlite(\@res, "madis");

my($daten) = `date +%Y%m%d.%H%M%S.%N`;
chomp($daten);
my($qfile) = "/var/tmp/querys/$daten-madis-get-raws-$$";
open(A,">$qfile");

# TODO: need to delete old entries from madis and madis_now (maybe)
print A "BEGIN;\n";

for $i (@queries) {
  # REPLACE if needed
  $i=~s/IGNORE/REPLACE/;
  print A "$i;\n";
  # and now for weather_now
  $i=~s/madis/madis_now/;
  print A "$i;\n";
}

print A "COMMIT;\n";
close(A);
