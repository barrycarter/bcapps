#!/bin/perl

# computes the minimum area required to get 270 electoral votes to answer https://www.quora.com/What-is-the-smallest-total-land-area-in-the-United-States-whose-100-vote-would-be-sufficient-to-elect-a-president

require "/usr/local/lib/bclib.pl";
use Storable;

my($db) = "/sites/DB/blockgroups.db";
my($workdir) = "/home/barrycarter/20160709";

# TODO: including water so allowing people who live on houseboats, but
# this may be bad idea

unless (-f "$workdir/stor.txt") {load_data();}

# data is in data.pl file, so load it
# eval(read_file("$workdir/data.pl"));
# debug($VAR1);

my($data) = retrieve("$workdir/stor.txt");


# load data into data.pl file in workdir

sub load_data {
  my(@totals) = sqlite3hashlist("SELECT statefp, SUM(aland+awater) AS atotal, SUM(population) AS ptotal FROM blockgroups GROUP BY statefp", $db);
  # most densely populated areas (not per state, but not an issue)
  my(@dense) = sqlite3hashlist("SELECT geoid, statefp, aland+awater AS area, population FROM blockgroups ORDER BY population/area DESC", $db);
#  write_file(Dumper([[@dense], [@totals]]), "$workdir/data.pl");
  store([[@dense], [@totals]], "$workdir/stor.txt");
}



