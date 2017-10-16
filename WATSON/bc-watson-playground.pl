#!/bin/perl

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# to hold results
my($out, $err, $res);

my($auth) = JSON::from_json($private{watson}{json});

# convenience variables
my($url, $user, $pass) = ($auth->{url}, $auth->{username}, $auth->{password});

# version string is required

my($vstring) = "version=2017-09-01";

# this assumes you've created an environment, a configuration inside
# that environment, and a collection inside the configuration (you can
# do all these things online using the GUI)

# TODO: caching only during testing
($out, $err, $res) = cache_command2("curl -u $user:$pass '$url/v1/environments?$vstring'", "age=300");

my($env) = JSON::from_json($out);

# the 0th environment is the system environment = "Shared system data sources"
my($envid) = $env->{'environments'}->[1]->{'environment_id'};

