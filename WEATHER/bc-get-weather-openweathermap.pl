#!/bin/perl

# As AERIS stops giving free API data, moving to openweathermap.org

require "/usr/local/lib/bclib.pl";
require "$bclib{home}/bc-private.pl";

# cache during testing only

if ($globopts{test}) {$age=3600;} else {$age=-1;}

my($out, $err, $res) = cache_command2("curl 'https://api.openweathermap.org/data/2.5/onecall?lat=$bclib{latitude}&lon=$bclib{longitude}&appid=$bclib{openweathermap}{appid}&units=imperial'", "age=$age");

my($json) = JSON::from_json($out);

# compute timestr

my($timestr) = strftime("@ %Y%m%d.%H%M%S", localtime($json->{current}->{dt}));

my($weather) = sprintf("%s/%0.1fF/%0.1fF/%d% (%0.1fF)\n", 
 $json->{current}->{weather}[0]->{description},
 $json->{current}->{temp},
 $json->{current}->{feels_like},
 $json->{current}->{humidity},
 $json->{current}->{dew_point}
);

print("$timestr\n$weather");





# TODO: personal weather station(s) [direct from HTML?] [existing prog?]
