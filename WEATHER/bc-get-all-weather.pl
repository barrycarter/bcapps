#!/bin/perl

# thin wrapper around bc-get-*.pl programs that runs forever

require "/usr/local/lib/bclib.pl";

# renice myself
system("/usr/bin/renice 19 -p $$");

# info in raws is also in mesonet, so pointless to run "raws" (maybe)
# for $i ("madis","buoy","guidance2","metar","ship","raws", "mesonet") {
for $i ("madis","buoy","guidance2","metar","ship", "mesonet") {
  debug("RUNNING: bc-get-$i.pl");
  system("bc-get-$i.pl");
}

# only run sqlite3 once, not after each download (too slow)
system("bc-query-gobbler.pl madis --append=/usr/local/etc/madis.sql");
sleep(60);
in_you_endo();
exec($0);
