#!/bin/perl

# does what bc-get-buoy.pl does but for METAR

# specifically, writes to STDOUT SQL commands to populate weather.db
# (does not actually run them)

require "/usr/local/lib/bclib.pl";

my($out,$err,$res) = cache_command2("curl http://weather.aero/dataserver_current/cache/metars.cache.csv.gz | gunzip | tail -n +6", "age=150");

# HACK: csv() does not handle ",," well
while ($out=~s/,,/, ,/isg) {}

# get rid of leading blank lines
$out=trim($out);

# this file is important enough to keep around
write_file($out, "/var/tmp/weather.aero.metars.txt");

# fields that copy over with different names
%convert = ("raw_text" => "observation", "station_id" => "id",
	   "wind_dir_degrees" => "winddir", "wx_string" => "events");

# the reports
my(@res) = split(/\n/, $out);

# header line
@headers = csv(shift(@res));

# go through data
for $i (@res) {
  my(@line) = csv($i);

  my(%hash) = ();

  for $j (0..$#headers) {
    # remove the space I added above (sigh)
    $line[$j]=~s/^\s*$//isg;
    $hash{$headers[$j]} = $line[$j];
  }
  # ignore 0 lat/lon (no wstations there)
  unless ($hash{latitude} || $hash{longitude}) {
    debug("BAD LINE: $i");
    next;
  }

  # create db hash from original hash
  # all observations are METAR
  $dbhash{type} = "METAR";

  # copyovers
  for $j ("latitude", "longitude") {$dbhash{$j} = $hash{$j};}

  for $j (keys %convert) {$dbhash{$convert{$j}} = $hash{$j};}

  # C to F
  $dbhash{temperature} = round2(convert($hash{temp_c},"c","f"),1);
  $dbhash{dewpoint} = round2(convert($hash{dewpoint_c},"c","f"),1);

  # minor changes
  $dbhash{time} = $hash{observation_time};
  $dbhash{time}=~s/t/ /;
  $dbhash{pressure} = round2($hash{altim_in_hg},2);

  # meters to feet
  $dbhash{elevation} = round2(convert($hash{elevation_m},"m","ft"),0);

  # knots to mph
  $dbhash{windspeed} = round2(convert($hash{wind_speed_kt},"kt","mph"),1);
  $dbhash{gust} = round2(convert($hash{wind_gust_kt},"kt","mph"),1);

  push(@hashes, {%dbhash});
}

@queries = hashlist2sqlite(\@hashes, "weather");

# need to delete old entries from weather and weather_now (maybe)
print "BEGIN;\n";

for $i (@queries) {
  # REPLACE if needed
  $i=~s/IGNORE/REPLACE/;
  print "$i;\n";
  # and now for weather_now
  $i=~s/weather/weather_now/;
  print "$i;\n";
}

print "COMMIT;\n";

# ugly function to round null to null
sub round2 {
  my($num,$digits) = @_;
  # TODO: improve this to deal with other strings
  if ($num eq "NULL") {return "NULL";}
  return sprintf("%0.${digits}f", $num);
}

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
