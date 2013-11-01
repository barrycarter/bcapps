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

$url = "http://api.mesowest.net/stations?bbox=-107,35,-106,36&status=active&complete=1&latestobs=1&token=$token";

($out,$err,$res) = cache_command2("curl '$url'", "age=3600");

# de-JSON-ify
$json = JSON::from_json($out);

debug(var_dump("json",$json));

# debug("JSON: $json");

# debug("OUT: $out");

