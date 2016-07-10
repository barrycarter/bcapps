#!/bin/perl

# computes the minimum area required to get 270 electoral votes to answer https://www.quora.com/What-is-the-smallest-total-land-area-in-the-United-States-whose-100-vote-would-be-sufficient-to-elect-a-president

require "/usr/local/lib/bclib.pl";
use Storable;

my($db) = "/sites/DB/blockgroups.db";
my($workdir) = "/home/barrycarter/20160709";

# TODO: including water so allowing people who live on houseboats, but
# this may be bad idea

# TODO: need people of voting age only
# TODO: need voting districts? or simple numbers might be ok

unless (-f "$workdir/stor.txt") {load_data();}

my($data) = retrieve("$workdir/stor.txt");
my($dense, $totals) = @$data;

# TODO: probably better way to do this
my(@dense) = @$dense;
my(@totals) = @$totals;

# TODO: shortcut abort when every state has 50%+

for $i (@dense) {

  debug(%$i);

  # TODO: store list of blockgroups since I'll want to map them eventually

  # compute total population and total area for this state
  $population{$i->{'statefp'}}+= $i->{'population'};
  $totalarea{$i->{'statefp'}}+= $i->{'area'};

  # testing
  debug("STATE: $i->{statefp} has $population{$i->{statefp}}, $totalarea{$i->{statefp}}");
}

# load data into data.pl file in workdir

sub load_data {
  my(@totals) = sqlite3hashlist("SELECT statefp, SUM(aland+awater) AS atotal, SUM(population) AS ptotal FROM blockgroups GROUP BY statefp", $db);
  # most densely populated areas (not per state, but not an issue)
  my(@dense) = sqlite3hashlist("SELECT geoid, statefp, aland+awater AS area, population FROM blockgroups ORDER BY population/area DESC", $db);
  store([[@dense], [@totals]], "$workdir/stor.txt");
}



