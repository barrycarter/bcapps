#!/bin/perl

# Finds and deletes nodes I created (since I'm "just testing" for now)

require "/usr/local/lib/bclib.pl";

# find my nodes
my($out, $err, $res) = cache_command("curl -s 'http://api.openstreetmap.org/api/0.6/changesets?display_name=barrycarter'", "age=3600");

debug("OUT: $out, ERR: $err");


