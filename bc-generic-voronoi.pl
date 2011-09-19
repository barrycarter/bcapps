#!/bin/perl

# Create many useful Voronoi-style maps

require "bclib.pl";
require "bc-kml-lib.pl";

# wunderground personal weather stations (PWS), NM only

open(A,"grep KNM db/wstations.txt|");

while (<A>) {
  chomp;

  # ok, if it's less than five minutes old...
  if (-f ("/tmp/pws-$_.xml") && (-M ("/tmp/pws-$_.xml") < 300/86400)) {next;}

  # TODO: hardcoding filenames here is bad, but can't use
  # cache_command, since I'm using parallel
  push(@cmd, "curl -s -o /tmp/pws-$_.xml 'http://api.wunderground.com/weatherstation/WXCurrentObXML.asp?ID=$_'");
}

write_file(join("\n",@cmd)."\n", "/tmp/pws-suck.sh");
system("parallel < /tmp/pws-suck.sh");

for $i (glob("/tmp/pws-*.xml")) {
  $data = read_file($i);

  # fill hash with data
  $hashref = {};
  while ($data=~s%<(.*?)>(.*?)</\1>%%) {$$hashref{$1}=$2};

  # ignore those sans station_id
  unless ($$hashref{station_id}) {next;}

  # and shuffle for voronoi_map
  ($$hashref{x}, $$hashref{y}, $$hashref{id}) = 
    ($$hashref{longitude}, $$hashref{latitude}, $$hashref{station_id});

  $$hashref{label} = "$$hashref{full} ($$hashref{temp_f})";
  debug("TEMP: $$hashref{temp_f}");
  $hue = 5/6-$$hashref{temp_f}/120;
  debug("HUE: $hue");
  $$hashref{color} = hsv2rgb($hue,1,1,"kml=1&opacity=c0");
  debug("COLOR: $$hashref{color}");

  push(@reports, $hashref);

  $time = str2time($hash{observation_time_rfc822});
}

debug(@reports);

$file = voronoi_map(\@reports);

system("cp $file /home/barrycarter/BCINFO/sites/TEST/testing.kmz");
