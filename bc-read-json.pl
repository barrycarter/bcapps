#!/bin/perl

# Trivial script to print JSON data nicely when json_pp and json_xs don't help

require "/usr/local/lib/bclib.pl";

my($data, $fname) = cmdfile();

my(@list) = JSON::from_json($data);

debug(var_dump("data", \@list));
