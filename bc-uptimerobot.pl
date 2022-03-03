#!/bin/perl

# given an API key on the command line that works with uptimerobot.com:

# https://api.uptimerobot.com/v2/getMonitors?api_key=[argument]

# report errors to ~/ERR/

# TODO: if result file is empty or doesnt have any status, that's an error

# -nocurl: dont actually query uptimerobot API (useful for testing)

require "/usr/local/lib/bclib.pl";

dodie('chdir("/var/tmp/uptimerobot")');

my(@errors);

unless ($#ARGV == 0) {die("Usage: $0 apikey");}

# TODO: caching is really only for testing

# NOTE: uptimerobot requires a POST even if you're not posting anything

my($out, $err, $res) = cache_command("curl -X POST -L \47https://api.uptimerobot.com/v2/getMonitors?api_key=$ARGV[0]\47 | tee api-results.txt", "age=3600");

# TODO: annoyingly, the API doesn't return a "time of test"

my($json) = JSON::from_json($out);

debug(var_dump("json", $json));

for $i (@{$json->{monitors}}) {

  # per https://uptimerobot.com/api/ 2 means up

  unless ($i->{status} == 2) {
    push(@errors, "nagios.uptimerobot.$i->{friendly_name} down");
  }

}

write_file_new(join("\n",@errors)."\n", "/home/barrycarter/ERR/uptimerobot.err");
