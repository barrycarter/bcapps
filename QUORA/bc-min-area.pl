#!/bin/perl

# computes the minimum area required to get 270 electoral votes to answer https://www.quora.com/What-is-the-smallest-total-land-area-in-the-United-States-whose-100-vote-would-be-sufficient-to-elect-a-president

require "/usr/local/lib/bclib.pl";
use Storable;

# square meters in a square mile
$m2pmi2 = 1609.344**2;

my($db) = "/sites/DB/blockgroups.db";
my($workdir) = "/home/barrycarter/20160709";

get_stuff();

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

# get totals into usable form

for $i (@totals) {
  $ptotal{$i->{'statefp'}} = $i->{'ptotal'};
  $atotal{$i->{'statefp'}} = $i->{'atotal'}/$m2pmi2;
}

# TODO: shortcut abort when every state has 50%+

my(%exclusions, %isstate);

for $i (@dense) {

  # convenience variable for state FIPS code
  my($fp) = $i->{'statefp'};

  # could've done this with query: keep track of everything that's a state
  $isstate{$fp} = 1;

  # skip those w/ population over half accounted for
  if ($exclusions{$fp}) {next;}

  # TODO: store list of blockgroups since I'll want to map them eventually

  # compute total population and total area for this state
  $population{$fp}+= $i->{'population'};
  $area{$fp}+= $i->{'area'}/$m2pmi2;

  # if population greater than 1/2, exclude state
  if ($population{$fp} > $ptotal{$fp}/2) {$exclusions{$fp} = 1;}
}

for $i (keys %isstate) {
  my(@list) = ($i, $abbrev{$i}, $name{$i}, $area{$i}, $atotal{$i},
	       $ptotal{$i}, $votes{$i});
}

#  printf("%s\t%d\t%d\t%d\t%0.2f%%\t%0.2f\n", $abbrev{$i}, $area{$i}, 
#	 $atotal{$i}, $votes{$i}, $area{$i}/$atotal{$i}*100,
#	 $votes{$i}/$area{$i}*1000);

# load data into data.pl file in workdir

sub load_data {
  my(@totals) = sqlite3hashlist("SELECT statefp, SUM(aland+awater) AS atotal, SUM(population) AS ptotal FROM blockgroups GROUP BY statefp", $db);
  # most densely populated areas (not per state, but not an issue)
  my(@dense) = sqlite3hashlist("SELECT geoid, statefp, aland+awater AS area, population FROM blockgroups ORDER BY population/area DESC", $db);
  store([[@dense], [@totals]], "$workdir/stor.txt");
}

# obtains electoral votes and state names

# TODO: this sets global variables = icky

sub get_stuff {

  # data dir
  my($dir) = "$bclib{githome}/QUORA/";

  my(@fips) = split(/\n/,read_file("fipscodes.csv"));

  for $i (@fips) {
    my($abb, $fips, $name) = split(/\,/, $i);
    $name=~s/\"//g;
    $abbrev{$fips} = $abb;
    $name{$fips} = $name;
    # need this reverse mapping for electoral votes
    $fips{$name} = $fips;

  }

  debug(%fips);


  my(@elec) = split(/\n/,read_file("electoralvotes.csv"));

  for $i (@elec) {
    my($name, $votes) = split(/\,/, $i);
    $name=~s/\"//g;
    debug("VOTES: $votes, NAME: $name, FIPS: ",$fips{uc($name)});
    $votes{$fips{uc($name)}} = $votes;
  }

}


# TODO: mention 11%

# TODO: mention house of rep vote (17 smallest states)

# TODO: Disclaim NE and ME

