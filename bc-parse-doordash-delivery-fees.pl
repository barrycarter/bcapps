#!/bin/perl

# parses list of all doordash restaurants to find reasonable delivery fees

require "/usr/local/lib/bclib.pl";

my($data, $fname) = cmdfile();

debug($data);

