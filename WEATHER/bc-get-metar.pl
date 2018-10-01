#!/bin/perl

# does what bc-get-buoy.pl does but for METAR

# specifically, writes to file SQL commands to populate madis.db so
# that bc-query-gobbler.pl can run them

require "/usr/local/lib/bclib.pl";

# load METAR data from stations.db
@res1 = sqlite3hashlist("SELECT * FROM stations","/sites/DB/stations.db");
for $i (@res1) {$statinfo{$i->{metar}} = $i;}

# TODO: handle case of sky_cover occurring three times

# URL updated (to https) 24 Feb 2018
# my($url) = "http://aviationweather.gov/adds/dataserver_current/current/metars.cache.csv.gz";
my($url) = "https://aviationweather.gov/adds/dataserver_current/current/metars.cache.csv.gz";

my($out,$err,$res) = cache_command2("curl $url | gunzip", "age=150");

# store unzipped results
write_file($out, "/var/tmp/weather.aero.metars.txt");

# HACK: csv() does not handle ",," well
while ($out=~s/,,/, ,/isg) {}
# get rid of everything to header line
$out=~s/^.*raw_text/raw_text/isg;

# multiple sky cover
$out=~s/sky_cover/"sky_cover".++$n/iseg;

# let arraywheaders2hashlist do the hard work
map(push(@res, [csv($_)]), split(/\n/,$out));
($hlref) = arraywheaders2hashlist(\@res);

debug("TEST2");

# the following list tells how to convert file fields to db fields. Format:
# file_field:db_field:from_unit:to_unit:round_digits
@convert = (
 "raw_text:observation",
 "station_id:id",
 "wind_dir_degrees:winddir",
 "wx_string:events",
 "latitude:latitude",
 "longitude:longitude",
 "temp_c:temperature:c:f:1",
 "dewpoint_c:dewpoint:c:f:1",
 "altim_in_hg:pressure:::2",
 "elevation_m:elevation:m:ft:0",
 "wind_speed_kt:windspeed:kt:mph:1",
 "wind_gust_kt:gust:kt:mph:1"
);

for $i (@{$hlref}) {

  debug(var_dump("i",$i));

  # reject positionless data (unless we can get it from %statinfo hash
  if ($i->{latitude}=~/^\s*$/ || $i->{longitude}=~/^\s*$/) {
    unless ($statinfo{$i->{station_id}}) {
      # TODO: restore this warning!
      warn("$i->{station_id}: no position data at all!");
      next;
    }

    debug("$i->{station_id}: filling in position info from db");
    for $j ("latitude", "longitude", "elevation") {
      $i->{$j} = $statinfo{$i->{station_id}}{$j};
    }
  }

  # the resulting hash
  my(%hash) = ();

  # ugly way of combining sky_cover[1234]
  my(%cover) = ();
  for $j ("1".."4") {$cover{$i->{"sky_cover$j"}}=1;}
  $hash{cloudcover} = join(" ",keys %cover);
  $hash{cloudcover} =~s/\s+/ /isg;
  $hash{cloudcover} = trim($hash{cloudcover});

  for $j (@convert) {
    my($f1,$f2,$u1,$u2,$r) = split(/:/,$j);
    # start by copying file field to hash field
    $hash{$f2} = $i->{$f1};
    # unit conversion
    if ($u1 && $u2) {$hash{$f2} = convert($hash{$f2},$u1,$u2);}
    # rounding
    if (length($r)) {$hash{$f2} = round2($hash{$f2},$r);}
    # empties
    unless ($hash{$f2}=~/\S/) {$hash{$f2} = "NULL";}
  }

  # special cases
  $hash{type} = "METAR-parsed";
  $hash{source} = $url;

  # TODO: read name off METAR files, don't just set to station
  # TODO: maybe compare csv lat/lon to db lat/lon
  unless ($statinfo{$hash{id}}) {warn "NO METAR INFO: $hash{id}";}
  $hash{name} = "$statinfo{$hash{id}}{city}, $statinfo{$hash{id}}{state}, $statinfo{$hash{id}}{country}";
  $hash{name}=~s/\s*,\s*,\s*/, /isg;
  $hash{name}=~s/\s*,\s*/, /isg;
  debug("ALPHA: $hash{id} -> $hash{name}");
  $hash{time} = $i->{observation_time};
  $hash{time}=~s/T/ /;
  $hash{time}=~s/Z//;

  push(@hashes, {%hash});

}

@queries = hashlist2sqlite(\@hashes, "madis");

my($daten) = `date +%Y%m%d.%H%M%S.%N`;
chomp($daten);
my($qfile) = "/var/tmp/querys/$daten-madis-get-metar-$$";
open(A,">$qfile");

print A "BEGIN;\n";

for $i (@queries) {
  # REPLACE if needed
  $i=~s/INSERT OR IGNORE/REPLACE/;
  print A "$i;\n";
}

print A "COMMIT;\n";
close(A);

=item headers

The list of data that METAR report provides:

visibility_statute_mi
sea_level_pressure_mb
corrected
auto
auto_station
maintenance_indicator_on
no_signal
lightning_sensor_off
freezing_rain_sensor_off
present_weather_sensor_off
wx_string
sky_cover
cloud_base_ft_agl
sky_cover
cloud_base_ft_agl
sky_cover
cloud_base_ft_agl
sky_cover
cloud_base_ft_agl
flight_category
three_hr_pressure_tendency_mb
maxT_c
minT_c
maxT24hr_c
minT24hr_c
precip_in
pcp3hr_in
pcp6hr_in
pcp24hr_in
snow_in
vert_vis_ft
metar_type

=cut
