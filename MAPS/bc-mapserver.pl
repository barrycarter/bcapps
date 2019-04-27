#!/bin/perl -0777

# TODO: I might be able to use this via xinetd or websocket proxy, see
# if I want do to that though

# The main map server

require "/usr/local/lib/bclib.pl";

# TODO: generalize these paths
require "$bclib{githome}/MAPS/bc-mapserver-lib.pl";
require "$bclib{githome}/MAPS/bc-mapserver-commands.pl";

my($ans) = process_command(str2hashref("cmd=time&foo=bar&i=hero"));

# user won't be able to call this, but I can for testing

for ($i=35; $i<36; $i += 1/$meta{landuse}{dataPointsPerDegree}) {
  for ($j=-107; $j<-106; $j += 1/$meta{landuse}{dataPointsPerDegree}) {
    $ans = landuse(str2hashref("lat=$i&lon=$j"));
    print "$i $j $ans->{value}\n";
  }
}

$ans = landuse(str2hashref("lat=35.05&lon=-106.5"));

debug(var_dump("ans", $ans));




