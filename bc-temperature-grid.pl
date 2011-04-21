#!/bin/perl

# colors google map using "grid" of temperatures
# TODO: make grid change w/ zoom level (== hard?)

push(@INC,"/usr/local/lib");
require "bclib.pl";
chdir(tmpdir());
system("pwd");

system("cp /sites/DB/metar.db .");
@res = sqlite3hashlist("SELECT -strftime('%s', replace(n.time, '-4-','-04-'))+strftime('%s', 'now') AS age, n.code, n.temperature, s.latitude, s.longitude FROM nowweather n JOIN stations s ON (n.code=s.metar) WHERE age>0 AND age<7200", "metar.db");

# go through all stations
for $i (@res) {
  %hash = %{$i};

  # for now, just latitude and longitude, later more accurate
  ($lat, $lon) = (floor($hash{latitude}), floor($hash{longitude}));

  # push to list of temperatures for this lat/lon
  push(@{$temps{$lat}{$lon}}, $hash{temperature});
}

debug(unfold(%temps));
