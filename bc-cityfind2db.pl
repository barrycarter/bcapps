#!/bin/perl

# Converts the output of bc-cityfind.pl into a CSV (trivial script I
# just happen to need)

require "/usr/local/lib/bclib.pl";

# my(@order) = split(/\,/,"city,state,country,latitude,longitude");

# below to join to FetLife cities later
# cityq = the pattern we searched for
# cityf = the pattern we matched (usually same as cityq, not always)
my(@order) = split(/\,/,"cityq,cityf,city,state,country,latitude,longitude");

my(%hash,@print);

my($data,$file) = cmdfile();

while ($data=~s%<response>(.*?)</response>%%s) {
  my($city) = $1;

  while ($city=~s%<(.*?)>(.*?)</\1>%%) {
    my($key,$val) = ($1,$2);
    # ugly hack because this is CSV
    $val=~s/\,//g;
    $hash{$key}=$val;
  }

  @print = @order;
  map($_=$hash{$_},@print);
  print join(",",@print),"\n";
}

=item db

To create a db from the output of this:

CREATE TABLE places (cityq TEXT, cityf TEXT, city TEXT, state TEXT,
country TEXT, latitude DOUBLE, longitude DOUBLE);

-- TODO: index cityq for join to fetlife table

LOAD DATA LOCAL INFILE 'output-of-this'
REPLACE INTO TABLE places FIELDS TERMINATED BY ',';

CREATE INDEX i1 ON places(cityq(20));

-- join to show missing cities

-- this can't be a temporary table because I use it from outside session

CREATE TABLE temp0 AS  SELECT DISTINCT jloc FROM kinksters;

SELECT jloc FROM temp0 k LEFT JOIN places p ON (k.jloc = p.cityq)
WHERE p.cityq IS NULL;

-- when done
DROP TABLE temp0;

=cut


