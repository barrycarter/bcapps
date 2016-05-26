#!/bin/perl

# TODO: not necess only such line

# Does things with US county subdivision data

# TODO: see .m version of this file

# TODO: answer: -0.093365*intptlong + 29.8953056335449;

# TODO: what does "Created for statistical purposes only." mean? is my
# use invalid? (if so, get from Mathematica shape data or something)

# TODO: not best way to split state!

require "/usr/local/lib/bclib.pl";

# excluding AK HI PR GU, allowing rest
# https://www.epa.gov/enviro/state-fips-code-listing

# can't use one in this dir, its compressed
my($db) = "/sites/DB/blockgroups.db";
my($where) = "(statefp<=56 AND statefp NOT IN (2, 15))";

# TODO: can verify directly with ogrinfo -sql

# TODO: http://factfinder.census.gov/faces/tableservices/jsf/pages/productview.xhtml?src=bkmk confirms 50 state total

# 155993065 west of -87.3228979110718
# 155993015 east of -87.3228979110718

# 155992983 north of 38.4412050247192
# 155993097 south of 38.4412050247192

# TODO: more margin of error

# total population
my($poptotal) = sqlite3val("SELECT SUM(population) AS pop FROM blockgroups WHERE $where", $db);

my($areatotal) = sqlite3val("SELECT SUM(aland+awater) AS area FROM blockgroups WHERE $where", $db);

my($val);

# i is in degrees
for ($i=0.1; $i<=180; $i+=0.1) {

  if ($i == 90) {next;}

  print "TIMESTAMP: ",time(),"\n";

  my($slope) = tan($i*$DEGRAD);

  $val = find_root_sql("SELECT IFNULL(SUM(population),0)-$poptotal/2
  AS val FROM blockgroups WHERE $where AND intptlat <= $slope*intptlon +
  PARAMETER", $db, min(-180,-180/$slope), max(180,180/$slope), 0);

  print "POP D$i S$slope $val\n";

  $val = find_root_sql("SELECT IFNULL(SUM(aland+awater),0)-$areatotal/2
  AS val FROM blockgroups WHERE $where AND intptlat <= $slope*intptlon +
  PARAMETER", $db, min(-180,-180/$slope), max(180,180/$slope), 0);

  print "AREA D$i S$slope $val\n";
}

# splitting longitude for population (can't do as slope)
my($midlon) = find_root_sql("SELECT
IFNULL(SUM(population),0)-$poptotal/2 AS val FROM blockgroups WHERE
$where AND intptlon < PARAMETER", $db, -180, 0);

# splitting latitude (could do as slope, but then couldn't do inversion)
my($midlat) = find_root_sql("SELECT
IFNULL(SUM(population),0)-$poptotal/2 AS val FROM blockgroups WHERE
$where AND intptlat < PARAMETER", $db, -90, 90);

print "MIDLON: $midlon\n";
print "MIDLAT: $midlat\n";

die "TESTING";


my($select) = "SUM(population) AS pop, SUM(aland+awater) AS area FROM
blockgroups";






# debug(find_root_sql("SELECT PARAMETER-7", "", 0, 10));



debug(find_root_sql("SELECT IFNULL(SUM(population),0)-158873024.5 AS val FROM blockgroups WHERE intptlat < PARAMETER", "/home/barrycarter/CENSUS/blockgroups.db", 0, 90));

debug(find_root_sql("SELECT IFNULL(SUM(population),0)-158873024.5 AS val FROM blockgroups WHERE intptlon < PARAMETER", "/home/barrycarter/CENSUS/blockgroups.db", -150, 0));

die "TESTING";

# the database
my($db) = "$bclib{githome}/QUORA/tracts.db";

# the select
my($select) = "SUM(pop10) AS popt, SUM(aland+awater) AS areat FROM tracts";

# the limiting condition for all queries
my($cond) = "usps NOT IN ('PR', 'AK', 'HI')";

my($tots) = sqlite3hashlist("SELECT $select WHERE $cond", $db);

# these values are 306675006 and 8081867092450 (if you google the
# first, you actually get results, but not for the second)
my($popt, $areat) = ($tots->{popt}, $tots->{areat});

# TODO: slopes greater than 1 are ok too
for ($i=-0.0934; $i<=-0.0933; $i+=0.00001) {
  my($pop,$area) = find_intercept($i);
  print "$i $pop $area\n";
#  if ($i==0) {next;}
#  my($j) = 1/$i;
#  ($pop,$area) = find_intercept($j);
#  print "$j $pop $area\n";
}

# given a slope, determines the line intercept that best divides
# nation into equal populations and areas

sub find_intercept {
  my($m) = @_;

  # create function for findroot()
  my($f) = sub {my(@a)=pop_area_below_line($m,$_[0]); return $a[0];};

  # note that the line's intercept is where the line would hit the
  # Greenwich meridian so can be ridiculously high (or low)

  # .001 in latitude is about 317ft
  my($pop) = findroot2($f, -1000, 1000, 0, "delta=.001");
  $f = sub {my(@a)=pop_area_below_line($m,$_[0]); return $a[1];};
  my($area) = findroot2($f, -1000, 1000, 0, "delta=.001");

  return ($pop,$area);

}

# given a line slope and intercept, return the percentage amount of
# land and population below that line minus 0.5

# NOTE: uses globals, not a true subroutine and not intended to be

sub pop_area_below_line {
  my($m,$b) = @_;
  my($q) = "SELECT $select WHERE $cond AND intptlat < $m*intptlong + $b";
  my($res) = sqlite3hashlist($q,$db);
  return ($res->{popt}/$popt-0.5, $res->{areat}/$areat-0.5);
}

=item queries

SELECT SUM(pop10) FROM counties WHERE usps NOT IN ('PR', 'AK', 'HI');

is 306675006

SELECT SUM(aland+awater) FROM counties WHERE 
 usps NOT IN ('PR', 'AK', 'HI');

is 8081867092450

SELECT SUM(pop10), SUM(aland+awater) FROM counties WHERE 
 usps NOT IN ('PR', 'AK', 'HI')
AND intptlat < 40;

is surprisingly close!

TODO: straight line vs geodesic (merctaor, no such thing)

TODO: mention gis.stack answer

=end


=item comment

CREATE TABLE tracts (
 usps TEXT, geoid TEXT,
 pop10 INT, hu10 INT, aland DOUBLE, awater DOUBLE,
 aland_sqmi DOUBLE, awater_sqmi DOUBLE,
 intptlat DOUBLE, intptlong DOUBLE
);

.separator \t
.import "/home/barrycarter/20160522/Gaz_tracts_national.txt" tracts

TODO: my numbers dont quite add up, maybe mention what I get vs official sources

=end

=item find_root_sql($query, $db, $l, $r)

Given a parametrized SQL $query on $db that returns a single value,
find the value of the parameter between $l and $r that returns 0.

The parameter should be given as PARAMETER (literal word "PARAMETER")

TODO: something silly about using "PARAMETER" above.

This is essentially a wrapper around findroot() but has some
additional value

TODO: move me to bclib.pl

=cut

sub find_root_sql {
  my($query, $db, $l, $r) = @_;

  # create function for findroot()
  my($f) = sub {
    my($parvalue) = @_;
    my($query2) = $query;
    $query2=~s/PARAMETER/$parvalue/e;
    debug("Q1: $query\nQ2: $query2\nPAR: $parvalue");
    debug("OUTPUT", sqlite3val($query2,$db));
    debug("RETURNING", sqlite3val($query2,$db));
    return sqlite3val($query2,$db);
    };

    # TODO: allow parameters to be based to parent function
    return findroot2($f, $l, $r, 0, "delta=0.00001"); 
}
