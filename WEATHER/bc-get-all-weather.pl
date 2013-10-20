#!/bin/perl

# thin wrapper around bc-get-*.pl programs that runs forever

require "/usr/local/lib/bclib.pl";

# info in raws is also in mesonet, so pointless to run "raws" (maybe)
# for $i ("madis","buoy","guidance2","metar","ship","raws", "mesonet") {
for $i ("madis","buoy","guidance2","metar","ship", "mesonet") {
  debug("RUNNING: bc-get-$i.pl");
  system("bc-get-$i.pl");
  system("bc-query-gobbler.pl --append=/usr/local/etc/madis.sql");
}

sleep(60);
in_you_endo();
exec($0);
