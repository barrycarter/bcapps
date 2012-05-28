#!/bin/perl

# Generates alternate names for various large cities and their
# county/state/country. Part of
# http://wordpress.barrycarter.info/index.php/sfcse-society-to-foster-cruelty-to-search-engines/

require "/usr/local/lib/bclib.pl";

# TODO: can I do this as a single efficient db query?
# TODO: change this to 100K or 10K; 1M is just for testing
# TODO: make LIMIT 20 a parameter

# alternate names for 20 large cities
$query = "SELECT * FROM altnames an JOIN geonames gn ON (an.geonameid = gn.geonameid) WHERE gn.population > 1000000 ORDER BY RANDOM() LIMIT 20";

# TODO: change db below to live copy, not semi-local one
@res = sqlite3hashlist($query,"/mnt/sshfs/geonames2.db");

debug(@res);
