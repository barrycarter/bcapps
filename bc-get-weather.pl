#!/bin/perl

# Gets local weather from wunderground API solely to print on X root window
require "bclib.pl";

# below is demo key, not my personal key
$key = "1bf62599411c7c17";

# obtain + JSON parse data
($out, $err, $res) = cache_command("curl http://api.wunderground.com/api/$key/conditions/forecast/astronomy/q/KABQ.json", "age=60");
$json = JSON::from_json($out);

# debug(unfold($json));

# debug(keys %{$json->{forecast}});

# <h>intermediate variables are for sissies!</h>
for $i (@{$json->{forecast}->{simpleforecast}->{forecastday}}) {
  debug("I: $i");
}

# debug(%{$json}{forecast});

for $i (keys %{$json{forecast}}) {
  debug("KEY: $i");
}

# debug($json{simpleforecast});

die "TESTING";

# main goal here it to minimize what I print and how

# forecast for next few days (compact format)
@days = ($out=~m%(<forecastday>.*?</forecastday>)%isg);

for $i (@days) {
  debug("I: $i");
}

# debug(@days);
debug("OUT: $out");
