#!/bin/perl

# Gets local weather from wunderground API solely to print on X root window
require "bclib.pl";

# below is demo key, not my personal key
$key = "1bf62599411c7c17";

# obtain + JSON parse data
($out, $err, $res) = cache_command("curl http://api.wunderground.com/api/$key/conditions/forecast/astronomy/q/KABQ.json", "age=60");
$json = JSON::from_json($out);

# <h>intermediate variables are for sissies!</h>
for $i (@{$json->{forecast}->{simpleforecast}->{forecastday}}) {

  debug("PER: $i->{period}");

  # for now, only want today/tomorrow forecost
  if ($i->{period} > 2) {next;}

  # I want date:conditions/hi/lo/%pop (probability of precipitation)
  push(@str, join("", $i->{date}->{day},":",$i->{conditions},"/",
	      $i->{high}->{fahrenheit}, "/", $i->{low}{fahrenheit}, "/",
	      $i->{pop},"%"));
}

debug("STR",@str);

# next two days
$str = join(",",@str);

# and write to file
write_file($str, "/home/barrycarter/ERR/forecast.err");
