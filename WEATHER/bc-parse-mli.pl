#!/bin/perl

# Parses master-location-identifier-database-20130801.csv which
# contains a few (albeit very few) stations that neither nsd nor ucar
# has

require "/usr/local/lib/bclib.pl";


@ls=split(/\n/,read_file("master-location-identifier-database-20130801.csv"));
# get rid of useless lines
for (1..4) {shift(@ls);}
# array-ify
map(push(@res, [csv($_)]), @ls);
($hlref) = arraywheaders2hashlist(\@res);

for $i (@{$hlref}) {

  debug(var_dump("i",$i));

  # if ICAO blank + stn_key is USaa(something), (something) is actual ICAO
  if ($i->{icao}=~/^\s*$/ && $i->{stn_key}=~s/^USaa//) {
    $i->{icao} = $i->{stn_key};
  }

  # ignore non-metar (for now?)
  # TODO: should I really ignore non-metar?

  # duplicate/triplicate testing below
#  unless ($i->{icao} eq "AYMD") {next;}
#  debug(var_dump("i",$i));
#  next;
#  warn "TESTING";

  # ignore things without lat/lon too
  $err = 0;
  for $j ("icao", "lat_prp", "lon_prp") {
    # just spaces and apostrophes
    if ($i->{$j}=~m/^[\'\s]*$/) {$err=1;}
  }
  if ($err) {
    debug("SKIPPING: $i->{icao} $i->{lat_prp} $i->{lon_prp}");
    next;
  }

  # no duplicates
  if ($seen{$i->{icao}}) {next;}
  $seen{$i->{icao}} = 1;

  # cheat to make city look nicer
  $i->{city}=~s/\|(.*)$/ ($1)/;

  # most fields can be used as is (region -> state)
  @l = ();
  for $j ("icao", "wmo", "city", "region", "country", "lat_prp", "lon_prp") {
    push(@l, $i->{$j});
  }

  # fix elevation
  push(@l, round2(convert($i->{elev_baro},"m","ft")));
  # and source
  push(@l, "http://www.weathergraphics.com/identifiers/master-location-identifier-database-20130801.csv");
  print join("\t",@l),"\n";
}

warn "Run bc-parse-stations.pl after running this program";

=item comment

hash->{'icao'} = 'KABQ';
hash->{'country'} = 'United States';
hash->{'elev_baro'} = '1619';
hash->{'lat_prp'} = '35.04019444';
hash->{'lon_prp'} = '-106.6091944';
hash->{'maslib'} = '723650';
hash->{'wmo'} = '72365';
hash->{'city'} = 'Albuquerque|Kirtland Addition';
hash->{'station_name_current'} = 'International Airport|Kirtland AFB';
hash->{'region'} = 'NM';
http://www.weathergraphics.com/identifiers/master-location-identifier-database-20130801.csv

=end

=item schema

Changing schema here SLIGHTLY (but can't change it too much; other
progs use this table):

CREATE TABLE stations ( 
 metar TEXT,
 wmobs INT, 
 city TEXT, 
 state TEXT, 
 country TEXT, 
 latitude DOUBLE, 
 longitude DOUBLE, 
 elevation DOUBLE,
 source TEXT 
);

CREATE INDEX i_metar ON stations(metar);

.separator "\t"

.import output-of-this-prog stations

=cut

