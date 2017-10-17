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

# this assumes you've created an environment, a configuration, and a
# collection inside the environment (you can do all these things
# online using the GUI)

# TODO: caching only during testing

# obtain the environment
($out, $err, $res) = cache_command2("curl -u $user:$pass '$url/v1/environments?$vstring'", "age=300");
my($env) = JSON::from_json($out);
my($envid) = $env->{'environments'}->[1]->{'environment_id'};
# debug("ENV: $out","ENVID: $envid");

# and now the collection
($out, $err, $res) = cache_command2("curl -u $user:$pass '$url/v1/environments/$envid/collections?$vstring'", "age=300");
my($coll) = JSON::from_json($out);
my($collid) = $coll->{'collections'}->[0]->{'collection_id'};
# debug("COLL: $out","COLLID: $collid");

# and the documents (nope)
($out, $err, $res) = cache_command2("curl -u $user:$pass '$url/v1/environments/$envid/collections/$collid?$vstring'", "age=300");

# the fields
($out, $err, $res) = cache_command2("curl -u $user:$pass '$url/v1/environments/$envid/collections/$collid/fields?$vstring'", "age=300");

# the docs filenames
# ($out, $err, $res) = cache_command2("curl -u $user:$pass '$url/v1/environments/$envid/collections/$collid/query?$vstring&return=enriched_text.entities.text'", "age=300");
# my($ents) = JSON::from_json($out);

# everything?
($out, $err, $res) = cache_command2("curl -u $user:$pass '$url/v1/environments/$envid/collections/$collid/query?$vstring&count=9999'", "age=300");
my($all) = JSON::from_json($out);

# show entities (from 0th book, Colour of Magic in this case)

my($ents) = $all->{'results'}->[0]->{'enriched_text'}->{'entities'};

for $i (@$ents) {
  debug("$i->{text} ($i->{type}) $i->{count}");
}

# debug(var_dump("ALL", $all));

# debug("OUT: $out");



# TODO: configuration might be largely eirrelevant

# and now the configuration inside the environment

# ($out, $err, $res) = cache_command2("curl -u $user:$pass '$url/v1/environments/$envid/configurations?$vstring'", "age=300");

# debug("OUT: $out");
