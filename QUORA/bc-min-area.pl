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

  # compute total population, area, blockgroups for this state
  $population{$fp}+= $i->{'population'};
  $area{$fp}+= $i->{'area'}/$m2pmi2;
  $bgs{$fp}++;

  # if population greater than 1/2, exclude state
  if ($population{$fp} > $ptotal{$fp}/2) {$exclusions{$fp} = 1;}
}

my(@head) = ("FIPS", "Abbreviation", "Name", "AreaHalf", "AreaTotal",
	     "PopHalf", "PopTotal", "ElectoralVotes", "BlockGroupsHalf");

print join("|",@head),"\n";

for $i (keys %isstate) {
  my(@list) = ($i, $abbrev{$i}, $name{$i}, $area{$i}, $atotal{$i},
	       $population{$i}, $ptotal{$i}, $votes{$i}, $bgs{$i});
  print join("|",@list),"\n";
}

#  printf("%s\t%d\t%d\t%d\t%0.2f%%\t%0.2f\n", $abbrev{$i}, $area{$i}, 
#	 $atotal{$i}, $votes{$i}, $area{$i}/$atotal{$i}*100,
#	 $votes{$i}/$area{$i}*1000);

# load data into data.pl file in workdir

sub load_data {
  # 72 = Puerto Rico
  my(@totals) = sqlite3hashlist("SELECT statefp, SUM(aland+awater) AS atotal, SUM(population) AS ptotal FROM blockgroups WHERE statefp NOT IN (72) GROUP BY statefp", $db);
  # most densely populated areas (not per state, but not an issue)
  my(@dense) = sqlite3hashlist("SELECT geoid, statefp, aland+awater AS area, population FROM blockgroups WHERE statefp NOT IN (72) ORDER BY population/area DESC", $db);
  store([[@dense], [@totals]], "$workdir/stor.txt");
}

# obtains electoral votes and state names

# TODO: this sets global variables = icky

sub get_stuff {

  # data dir
  my($dir) = "$bclib{githome}/QUORA/";

  my(@fips) = split(/\n/,read_file("$dir/fipscodes.csv"));

  for $i (@fips) {
    my($abb, $fips, $name) = split(/\,/, $i);
    $name=~s/\"//g;
    $abbrev{$fips} = $abb;
    $name{$fips} = $name;
    # need this reverse mapping for electoral votes
    $fips{$name} = $fips;

  }

  my(@elec) = split(/\n/,read_file("$dir/electoralvotes.csv"));

  for $i (@elec) {
    my($name, $votes) = split(/\,/, $i);
    $name=~s/\"//g;
    $votes{$fips{uc($name)}} = $votes;
    # this proper cases the name
    $name{$fips{uc($name)}} = $name;
  }

}


=item comment

(text of answer)

Roughly speaking, if you could secure every vote in a specific non-contiguous 11,406 square mile area, you would have the necessary 270 electoral votes to win the Presidency. This is 0.3% of the total area of the portion of United States that votes (3,796,788 square miles, which includes all 50 states and the District of Columbia, but not Puerto Rico and other non-voting territories or possesions).

Following this plan, you would obtain 27.5% of all votes, which would nonetheless be sufficient to obtain over 270 electoral votes.

This question fascinated me, so I created the following table (which I explain below):

[[election.png]]

(a potentially more useful version of this table appears at http://a4c33c9841f29cde8436a61a84163912.elections.db.94y.info/ but doesn't have running totals)

Explaining this chart using Rhode Island (RI) as an example:

  - Rhode Island has a population of 1,053,252 people (2nd column) and a total area of 1,545 square miles (4th column). However, over half the people in Rhode Island live in a 72 square mile area (3rd column).

  - In other words, over half of Rhode Island's population lives in just 4.65% (5th column) of Rhode Island's area.

  - Rhode Island has a total of 4 electoral votes (6th column).

  - If you could convince everyone in the 72 square miles that hold Rhode Island's majority to vote for you, you would win all 4 electoral votes, since most states award electoral votes on an all-or-none basis: https://en.wikipedia.org/wiki/Electoral_College_%28United_States%29

  - 4 electoral votes for 72 square miles is 0.05568 electoral votes per square mile. To make this number more reasonable, I give this number as electoral votes per 1000 square miles (7th column). Of course, the number for Rhode Island (55.68) is higher than the number of electoral votes, since we're only visiting 72 square miles, and not 1000 square miles.

Methodology/Errata:

  - census.gov divides the USA into 220,333 "block groups" ( https://www.census.gov/geo/reference/gtc/gtc_bg.html ) with a mean of about 1500 people per block group (the actual number of people per block group varies significantly, from as low as zero to just under 40,000).

  - Under "2010 - 2014 Detailed Tables" on https://www.census.gov/geo/maps-data/data/tiger-data.html I downloaded the "Block Group" national file. Direct link to this 1.6GB file http://www2.census.gov/geo/tiger/TIGER_DP/2014ACS/ACS_2014_5YR_BG.gdb.zip (reminder to GIS users: do NOT unzip this file; some GIS software will break the unzipped version of this file), which contains the 2014 population estimates per block group.

  - Not everyone in a block group (or in the United States) votes. To vote, a person must:

    - Be a citizen of the United States

    - Be of the age required by local government (but 18 or older can always vote)

    - Not be currently imprisoned for a felony (some states prohibit former felons from voting as well)

    - Be registered to vote

    - Actually vote

I don't assume everyone in a block group votes, but I do assume voting is proportional. In other words, I assume the number of voters in a block group of 2000 people is exactly twice the number of voters in a block group of 1000 people. This probably isn't true, and this answer can be refined by compensating for this mistake.





# TODO: wrong file? but see http://factfinder.census.gov/faces/tableservices/jsf/pages/productview.xhtml?src=bkmk




# TODO: all or none



# TODO: fascinating 7.5% fact


# TODO: non voters and proportionality assumption

# TODO: link to more mutable chart

# TODO: mention this program

# TODO: source info

# TODO: source cenus data, see bc-us-split.m

# TODO: mention 11%

# TODO: mention house of rep vote (17 smallest states)

# TODO: Disclaim NE and ME









=cut
