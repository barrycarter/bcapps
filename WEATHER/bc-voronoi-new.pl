#!/bin/perl

# Creates a Voronoi diagram (or maybe a contourplot) from temperature
# data in metarnew.db database

require "/usr/local/lib/bclib.pl";

# temporary db for testing (is local)
$db = "/home/barrycarter/20130908/metarnew.db";

$metar_query = "SELECT station_id, latitude, longitude, temp_c*1.8+32 AS temp_f FROM metar_now";
$buoy_query = "SELECT STN AS station_id, LAT AS latitude, LON AS longitude,
ATMP*1.8+32 AS temp_f FROM buoy_now WHERE ATMP!='MM'";
$ship_query = "SELECT station_id, latitude, longitude, temp_c*1.8+32 AS temp_f FROM ship_now WHERE temp_c!=''";

$query = "$metar_query UNION $buoy_query UNION $ship_query";

# warn "TESTING";
@res = sqlite3hashlist($query,$db);

# mathematica format (testing)
my(@print);
for $i (@res) {
  # this is an error that I've fixed, but need to ignore for now
  if ($i->{longitude}=~/\-$/) {next;}
  # not sure what causes this..
  if (abs($i->{latitude})>90) {next;}

  push(@print,"{$i->{longitude}, $i->{latitude}, $i->{temp_f}}");
}

print "list = {\n";
print join(",\n",@print);
print "}\n";

