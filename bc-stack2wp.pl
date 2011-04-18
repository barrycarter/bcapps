#!/bin/perl

# Attempt to pull my stackexchange questions (not answers) into
# wordpress.barrycarter.info

# NOTE: stack API results are gzip compressed

require "bclib.pl";

# work in my own directory
chdir(tmpdir());

# TODO: cheating and hardcoding this, but could get it from any of my stack ids
$assoc_id = "aa1073f7-7e3b-4d4d-ace5-f2fca853f998";

# ($out, $err, $stat) = cache_command("curl http://stackauth.com/1.1/sites?page=1&pagesize=2147483647&minimal=true","age=86400");

# ($out, $err, $stat) = cache_command("curl 'http://stackauth.com/1.1/sites?page=1&pagesize=10&minimal=true'","age=86400");

# find all my ids

$fname = cache_command("curl 'http://stackauth.com/1.1/users/$assoc_id/associated'","age=86400&retfile=1");

# unzip results
system("gunzip -c $fname > json1");

debug(read_file("json1"));


