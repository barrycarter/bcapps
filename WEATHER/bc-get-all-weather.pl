#!/bin/perl

# thin wrapper around bc-get-*.pl programs that runs forever

require "/usr/local/lib/bclib.pl";

# write my own query to cleanup db
my($daten) = `date +%Y%m%d.%H%M%S.%N`;
chomp($daten);
my($qfile) = "/var/tmp/querys/$daten-madis-kill-rows-$$";
open(A,">$qfile");
print A "DELETE FROM madis WHERE temperature='NULL';\n";
close(A);

# info in raws is also in mesonet, so pointless to run "raws"
# for $i ("madis","buoy","guidance2","metar","ship","raws", "mesonet") {
for $i ("madis","buoy","guidance2","metar","ship", "mesonet") {
  debug("RUNNING: bc-get-$i.pl");
  system("bc-get-$i.pl");
  system("bc-query-gobbler.pl --vacuum");
}

sleep(60);
in_you_endo();
exec($0);
