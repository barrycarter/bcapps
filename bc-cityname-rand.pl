#!/bin/perl

# Generates alternate names for various large cities and their
# county/state/country. Part of
# http://wordpress.barrycarter.info/index.php/sfcse-society-to-foster-cruelty-to-search-engines/

require "/usr/local/lib/bclib.pl";

# TODO: can I do this as a single efficient db query?
# TODO: change this to 100K or 10K; 1M is just for testing
# TODO: make LIMIT 20 a parameter

# 20 cities over 1M, and the altnames for them, their admin4, etc; see also
# http://b1a018382a48c44e5ebb44a956b7c815.geonames.db.barrycarter.info/
# <h>or don't, it's hideous!</h>
$query = "SELECT * FROM (SELECT * FROM geonames WHERE population > 1000000 ORDER BY RANDOM() LIMIT 20) AS t JOIN altnames an ON (an.geonameid IN (IFNULL(t.geonameid,0), IFNULL(t.admin4_code,0), IFNULL(t.admin3_code,0), IFNULL(t.admin2_code,0), IFNULL(t.admin1_code,0), IFNULL(t.country_code,0)))";

# TODO: change db below to live copy, not semi-local one
@res = sqlite3hashlist($query,"/mnt/sshfs/geonames2.db");
