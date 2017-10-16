#!/bin/perl

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";


debug($private{watson}{json});
debug(var_dump("json",(JSON::from_json($private{watson}{json}))));
