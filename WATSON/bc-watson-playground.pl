#!/bin/perl

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";


# only while testing
my($cache) = 3600;

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
($out, $err, $res) = cache_command2("curl -u $user:$pass '$url/v1/environments?$vstring'", "age=$cache");
my($env) = JSON::from_json($out);
my($envid) = $env->{'environments'}->[1]->{'environment_id'};
debug("ENV: $out","ENVID: $envid");

# TODO: configuration might be largely eirrelevant

# and now the configuration inside the environment

($out, $err, $res) = cache_command2("curl -u $user:$pass '$url/v1/environments/$envid/configurations?$vstring'", "age=300");

debug("OUT: $out");

die "TESTING";

# and now the collection
($out, $err, $res) = cache_command2("curl -u $user:$pass '$url/v1/environments/$envid/collections?$vstring'", "age=$cache");
my($coll) = JSON::from_json($out);
my($collid) = $coll->{'collections'}->[0]->{'collection_id'};
# debug("COLL: $out","COLLID: $collid");

# and the documents (nope)
($out, $err, $res) = cache_command2("curl -u $user:$pass '$url/v1/environments/$envid/collections/$collid?$vstring'", "age=$cache");

# the fields
($out, $err, $res) = cache_command2("curl -u $user:$pass '$url/v1/environments/$envid/collections/$collid/fields?$vstring'", "age=$cache");

# the docs filenames
# ($out, $err, $res) = cache_command2("curl -u $user:$pass '$url/v1/environments/$envid/collections/$collid/query?$vstring&return=enriched_text.entities.text'", "age=300");
# my($ents) = JSON::from_json($out);

# everything?
($out, $err, $res) = cache_command2("curl -u $user:$pass '$url/v1/environments/$envid/collections/$collid/query?$vstring&count=9999'", "age=$cache");
my($all) = JSON::from_json($out);

# TODO: identify which entity is being displayed (via metadata or something)

for $j (@{$all->{'results'}}) {

  debug(var_dump("j",$j));
  my(@ents) = $j->{'enriched_text'}->{'entities'};
  debug("NEW ENT!");

  for $i (sort {$b->{count} <=> $a->{count}} @$ents) {
    debug("$i->{text} ($i->{type}) $i->{count}");
  }

}

die "TESITNG";;

# show entities (from 0th book, Colour of Magic in this case)

my($ents) = $all->{'results'}->[2]->{'enriched_text'}->{'entities'};

for $i (sort {$b->{count} <=> $a->{count}} @$ents) {
  debug("$i->{text} ($i->{type}) $i->{count}");
}

# debug(var_dump("ALL", $all));

# debug("OUT: $out");



