#!/bin/perl

# Gets local weather from wunderground API solely to print on X root window
# runs from cron every 10m
# -show: print out string I send to file
# -test: in testing mode, use cached data more

# being rewritten on 2 Oct 2018 as wunderground stops giving out free keys

require "/usr/local/lib/bclib.pl";
$now = time();

warn "testing";

$globopts{test} = 1;

# obtain + JSON parse data (caching solely for testing)
if ($globopts{test}) {$age=300;} else {$age=-1;}

# 102,118 is the grid where I live (in Albuquerque)
($out, $err, $res) = cache_command2("curl https://api.weather.gov/gridpoints/ABQ/102,118", "age=$age");

debug("OUT: $out");
$json = JSON::from_json($out);

die "TESTING";

# <h>intermediate variables are for sissies!</h>
for $i (@{$json->{forecast}->{simpleforecast}->{forecastday}}) {

  # to save screen "real estate", shorten some conditions
  # TODO: do this better
  # TODO: do this for current_observation -> weather as well
  $i->{conditions}=~s/clear/CLR/isg;
  $i->{conditions}=~s/partly cloudy/PCL/isg;
  $i->{conditions}=~s/mostly cloudy/MCL/isg;
  $i->{conditions}=~s/chance of a thunderstorm/TSTRM?/isg;
  $i->{conditions}=~s/chance of rain/RAIN?/isg;
  $i->{conditions}=~s/chance rain/RAIN?/isg;
  $i->{conditions}=~s/thunderstorm/TSTRM!/isg;
  $i->{conditions}=~s/ice pellets/SLEET/isg;

  # want colons to line up!
  $i->{date}->{day}=~s/^(\d)$/0$1/;

  # I want date:conditions/hi/lo/%pop (probability of precipitation)
  push(@forecast, join("", $i->{date}->{weekday_short},$i->{date}->{day},":",$i->{conditions},"/",
	      $i->{high}->{fahrenheit}, "/", $i->{low}{fahrenheit}, "/",
	      $i->{pop},"%"));
}

# now, current: conditions/temp/wc/humid (dewpt)

  $current = join("",
		$json->{current_observation}->{weather}, "/",
		$json->{current_observation}->{temp_f}, "F/",
		$json->{current_observation}->{windchill_f}, "F/",
		$json->{current_observation}->{relative_humidity}, " (",
		$json->{current_observation}->{dewpoint_f}, "F)"
	       );

# time of obs (compacted w/ time first)
$time = $json->{current_observation}->{observation_time};
# get rid of useless string and tz
$time=~s/^last updated on //isg;
# this IS case sensitive
$time=~s/\s*[A-Z]+$//;
$time=~s/^(.*?),\s*(.*?)$/$2, $1/;

# wind and pressure (dir spdGgust (press))
# treat no gust special
unless ($json->{current_observation}->{wind_gust_mph}) {
  $json->{current_observation}->{wind_gust_mph} = "";
}

$wind = join("", 
	     $json->{current_observation}->{wind_dir}, " ",
	     $json->{current_observation}->{wind_mph}, "G",
	     $json->{current_observation}->{wind_gust_mph}, " (",
	     $json->{current_observation}->{pressure_in}, "in)"
);

# moon info now printed by bc-get-astro, removed below
$forecast = join("\n",@forecast[0..6]);

# print in order I want (even if I change mind later)
# some astro functions absorbed by bc-get-astro.pl
$str = << "MARK";
\@$time
$current
$wind
$forecast
MARK
;

# there really aren't 6 days of forecasts but adding blank lines doesn't hurt

if ($globopts{show}) {print $str;}

# and write to info file
write_file_new($str, "/home/barrycarter/ERR/forecast.inf");
