#!/bin/perl

# this replaces run_test in bc-nagyerass.pl

# Given a test (in any form <> can read), log it, run it, write to ~/ERR, etc

require "/usr/local/lib/bclib.pl";

# if this directory doesn't exist, we don't even bother with a regular error

# TODO: is above wise?

my($logdir) = "/usr/local/etc/nagyerass";

my($errdir) = "/home/user/ERR";

my($out, $err, $res, $snow);

dodie('chdir("/usr/local/etc/nagyerass")');

my(%hash);

while (<>) {

  # ignore comments

  if (m%^#%) {next;}

  # all lines in the test itself should be key=val

  unless (m%^(.*?)\=(.*)$%) {fail("non key/val line found: $_");}

  my($key, $val) = ($1, $2);

  if ($hash{key}) {fail("Redefined key error: $_");}

  $hash{$key} = $val;

}

# we use name for many things

unless ($hash{name}) {fail("No anonymous tests!");}

# TODO: confirm test isnt already running by looking at last line of log file

# TODO: could use fuser or mylock here too

# its ok for there to be no log file, but, if there is...

if (-f "$logdir/$hash{name}.log") {
  ($out, $err, $res) = cache_command2("tail -n 1 $logdir/$hash{name}.log");

  if ($res) {fail("Could not open log file");}
  
  unless ($out=~/END$/) {fail("$hash{name}: Previous run not finished");}

}

# we now log the start of this test (putting $hash{name} here is redundant)

$snow = stardate();

append_file("$snow $hash{name} START", "$logdir/$hash{name}.log");

# finally, we are ready to actually run the test

($out, $err, $res) = cache_command2($hash{cmd});

# report the result

$snow = stardate();

append_file("$snow $hash{name} RESULT: $out", "$logdir/$hash{name}.log");

$snow = stardate();

append_file("$snow $hash{name} END", "$logdir/$hash{name}.log");

if ($res) {fail("Status: $res");}

# if success, wipe out ERR file

write_file("", "$errdir/$hash{name}.err.new");

mv_after_diff("$errdir/$hash{name}.err");

sub fail {

  my($str) = @_;

  # write to log file and errfile

  append_file("$snow $hash{name} FAIL: $str", "$logdir/$hash{name}.log");

  write_file("nagyerass.$hash{name}.$str", "$errdir/$hash{name}.err.new");

  mv_after_diff("$errdir/$hash{name}.err");

  exit(2);

}

