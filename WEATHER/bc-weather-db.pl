#!/bin/perl

# attempts to create a consolidated weather database from all sources

require "/usr/local/lib/bclib.pl";
require "/usr/local/lib/bc-weather-lib.pl";

# TODO: add more fields

# metars
@metars = recent_weather();

# pressure => altim_in_hg
# wind_dir_degrees => wind_direction

for $i (@metars) {
  %hash = ();

  $hash{data_source} = "http://weather.aero/dataserver_current/cache/metars.cache.csv.gz";

  # identical
  for $j ("station_id", "latitude", "longitude") {
    $hash{$j} = $i->{$j};
  }

  # different names
  $hash{pressure} = $i->{altim_in_hg};
  $hash{wind_direction} = $i->{wind_dir_degrees};

  $hash{observation_time} = $i->{observation_time};
  $hash{observation_time}=~s/z$//isg;

  $hash{elevation} = $i->{elevation_m}*3.28084;

  $hash{temperature} = $i->{temp_c}*1.8+32;
  $hash{dewpoint} = $i->{dewpoint_c}*1.8+32;

  $hash{wind_speed} = $i->{wind_speed_kt}*1.15078;
  $hash{wind_gust} = $i->{wind_gust_kt}*1.15078;

  debug("WS: $hash{wind_speed}, $i{wind_speed_kt}");

  push(@hashlist,{%hash});
}

print "BEGIN;\n";
@queries = hashlist2sqlite(\@hashlist, "weather");
for $i (@queries) {
  $i=~s/IGNORE/REPLACE/;
  print "$i;\n";
}
print "COMMIT;\n";


sub do_ships {
  @ships = recent_weather_ship();
  for $i (@ships) {
    debug(dump_var("i",$i));
  }
}

=item schema

CREATE TABLE weather (
 data_source, -- URL source of data
 station_id, -- unique station identifier
 observation_time, -- observation time as yyyy-mm-ddThh:mm:ss UTC
 latitude, -- latitude in degrees (negative for south)
 longitude, -- longitude in degrees (negative for west)
 elevation, -- elevation, in feet
 temperature, -- temperature in degrees Farenheit
 dewpoint, -- dewpoint in degrees Farenheit
 wind_direction, -- wind direction in degrees (0=360=from the north)
 wind_speed, -- wind speed in mph
 wind_gust, -- wind gust in mph
 pressure, -- barometric pressure in inches, adjusted to sea level
 comments, -- unformatted comments about this observation (usually blank)
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX i1 ON weather(station_id, observation_time);

=cut

