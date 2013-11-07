#!/bin/perl

# experiments with http://api.mesowest.net/ (currently in beta-testing)

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# obtain a token (and keep it for a while)
# to use this program, you must request your own key (I can't share, sorry!)
my($cmd) = "curl 'http://api.mesowest.net/auth?apikey=$mesowest{key}'";
my($out,$err,$res) = cache_command2($cmd,"age=3600");
unless ($out=~/TOKEN\":\s*\"(.*?)\"/) {die "NO TOKEN";}
my($token) = $1;

# $url = "http://api.mesowest.net/stations?bbox=-110,35,-100,40&token=$token";
# $url = "http://api.mesowest.net/stations?&state=dc,de&jsonformat=1&token=$token";
# $url = "http://api.mesowest.net/stations?&st&token=$token";
# $url = "http://api.mesowest.net/stations?bbox=-110,35,-100,40&status=active&complete=1&token=$token";
# $url = "http://api.mesowest.net/stations?bbox=-107,35,-106,36&status=active&complete=1&token=$token";
# $url = "http://api.mesowest.net/stations?bbox=-107,35,-106,36&status=active&complete=1&latestobs=1&token=$token";

$url = "http://api.mesowest.net/stations?bbox=-120,30,-90,50&status=active&complete=1&latestobs=1&json_format=2&vars=air_temp,dew_point_temperature,wind_speed,wind_direction,wind_gust,pressure,weather_cond_code,qc,remark,raw_ob,air_temp_high_6_hour,air_temp_low_6_hour,air_temp_high_24_hour,air_temp_low_24_hour,created_time_stamp,last_modified&token=$token";

($out,$err,$res) = cache_command2("time curl '$url'", "age=3600");
$out = wrap($out,79);
debug("OUT: $out, ERR: $err, RES: $res");

# de-JSON-ify
$json = JSON::from_json($out);

# debug(var_dump("json",$json));

# debug("JSON: $json");

# debug("OUT: $out");

