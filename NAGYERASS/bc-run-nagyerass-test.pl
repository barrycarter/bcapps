#!/bin/perl

# this replaces run_test in bc-nagyerass.pl

# Given a test (in any form <> can read), log it, run it, write to ~/ERR, etc

require "/usr/local/lib/bclib.pl";

# if this directory doesn't exist, we don't even bother with a regular error

# TODO: is above wise?

my($logdir) = "/usr/local/etc/nagyerass";

my($errdir) = "/home/user/ERR";

dodie('chdir("/usr/local/etc/nagyerass")');

my(%hash);

while (<>) {

  # all lines in the test itself should be key=val

  unless (m%^(.*?)\=(.*)$%) {fail("non key/val line found: $_");}

  my($key, $val) = ($1, $2);

  if ($hash{key}) {fail("Redefined key error: $_");}

  $hash{$key} = $val;

}

# we use name for many things

unless ($hash{name}) {fail("No anonymous tests!");}

# TODO: confirm test isnt already running

my($lock) = mylock("nagyerass-$hash{name}", "lock");

unless ($lock) {fail("Could not get lock: nagyerass-$hash{name}");}




sub fail {

  my($str) = @_;

  die($str);

  # this subroutine handles fails of many kinds

}

debug(%hash)



# slurp mode (nah)

# local($/);

# my($all) = <>;

# debug("ALL: $all");

