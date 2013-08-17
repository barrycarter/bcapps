#!/bin/perl

# attempts to create a consolidated weather database from all sources

require "/usr/local/lib/bclib.pl";
require "/usr/local/lib/bc-weather-lib.pl";

@ships = do_ships();

@qships = hashlist2sqlite(\@ships, "weather");
print "BEGIN;\n";
for $i (@qships) {
  $i=~s/IGNORE/REPLACE/;
  print "$i;\n";
}
print "COMMIT;\n";

# TODO: add more fields

sub do_metars {
  my(@metars) = recent_weather();
  my(@hashlist);
  for $i (@metars) {
    my(%hash) = ();
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
    push(@hashlist,{%hash});
  }

  return @hashlist;
}

sub do_ships {
  @ships = recent_weather_ship();
  for $i (@ships) {
    debug("I",dump_var($i));
    my(%hash) = ();
    $hash{data_source} = "http://coolwx.com/buoydata/data/curr/all.html";
    for $j ("station_id", "latitude", "longitude") {
      $hash{$j} = $i->{$j};
    }

    # figure out observation_time
    my($day,$hour) = split(/\//,$i->{day});
    my($mon,$year) = day2time($day,$hour);
    $hash{observation_time} = sprintf("%04d-%02d-%02dT%02d:00:00", $year,$mon,$day,$hour);

    # ships are at sea level (hopefully)
    $hash{elevation} = 0;

    $hash{temperature} = $i->{temp_c}*1.8+32;
    $hash{dewpoint} = $i->{dewpoint_c}*1.8+32;

    # wind direction and speed
    # TODO: do ships report wind in the "to" direction unlike METAR?
    $i->{wind}=~/^(...)(.*)$/;
    my($dir,$sp) = ($1,$2);
    $hash{wind_direction} = $dir;
    $hash{wind_speed} = $sp*1.15078;
    debug("$i->{wind} becomes $sp/$dir");

    $i->{gust}=~s/[a-z]//isg;
    $hash{wind_gust} = $i->{gust}*1.15078;

    $hash{pressure} = $i->{sea_level_pressure_mb}*0.0295333727;
    push(@hashlist,{%hash});
  }
  return @hashlist;
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

CREATE UNIQUE INDEX i1 ON weather(data_source, station_id, observation_time);

=cut

