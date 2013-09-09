#!/bin/perl

# Creates a Voronoi diagram (or maybe a contourplot) from temperature
# data in metarnew.db database

require "/usr/local/lib/bclib.pl";

# temporary db for testing (is local)
$db = "/home/barrycarter/20130908/metarnew.db";

$query = << "MARK";

SELECT station_id, latitude, longitude, temp_c*1.8+32 AS temp_f FROM
metar_now UNION
SELECT STN AS station_id, LAT AS latitude, LON AS longitude,
ATMP*1.8+32 AS temp_f FROM buoy_now WHERE ATMP!='MM' UNION
SELECT station_id, latitude, longitude, temp_c*1.8+32 AS temp_f FROM
ship_now WHERE temp_c!=''

MARK
;

@res = sqlite3hashlist($query,$db);

# mathematica format (testing)
my(@print);
for $i (@res) {
  # this is an error that I've fixed, but need to ignore for now
  if ($i->{longitude}=~/\-$/) {next;}
  push(@print,"{$i->{longitude}, $i->{latitude}, $i->{temp_f}}");
}

print "list = {\n";
print join(",\n",@print);
print "}\n";

