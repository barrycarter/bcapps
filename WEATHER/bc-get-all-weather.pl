#!/bin/perl

# thin wrapper around bc-get-*.pl programs that runs forever

require "/usr/local/lib/bclib.pl";

for $i ("madis","buoy","guidance2","metar","ship","raws", "mesonet") {
  debug("RUNNING: bc-get-$i.pl");
  system("bc-get-$i.pl");
  system("bc-query-gobbler.pl");
}

sleep(60);
in_you_endo();
exec($0);
