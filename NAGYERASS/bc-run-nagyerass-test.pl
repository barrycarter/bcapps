#!/bin/perl

# this replaces run_test in bc-nagyerass.pl

# Given a test (in any form <> can read), log it, run it, write to ~/ERR

require "/usr/local/lib/bclib.pl";

# slurp mode

local($/);

my($all) = <>;

debug("ALL: $all");
