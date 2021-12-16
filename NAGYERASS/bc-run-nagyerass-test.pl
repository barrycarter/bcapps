#!/bin/perl

# this replaces run_test in bc-nagyerass.pl

# Given a test (in any form <> can read), log it, run it, write to ~/ERR, etc

require "/usr/local/lib/bclib.pl";

warn("temporarily debugging everything");
defaults("debug=1");

my($logdir) = "/usr/local/etc/nagyerass/logs";
my($errdir) = "/home/user/ERR";
my($out, $err, $res, $snow);

# if this directory doesn't exist, we don't even bother with a regular error
# TODO: is above wise?

dodie('chdir("/usr/local/etc/nagyerass")');

# slurp the stdin or file

local $/;
my($stdin) = <STDIN>;

# grab xml tags

my(%hash);

while ($stdin=~s%<(.*?)>(.*?)</\1>%%) {

  my($key, $val) = ($1, $2);

  if ($hash{key}) {fail("Redefined key error: $_");}

  $hash{$key} = $val;

}

# if anything left, bad

unless ($stdin=~/^\s*$/) {
  fail("leftover: $stdin");
}

# we use name for many things

unless ($hash{name}) {fail("No anonymous tests!");}

# TODO: could use fuser or mylock here too

# its ok for there to be no log file, but, if there is...

if (-f "$logdir/$hash{name}.log") {
  ($out, $err, $res) = cache_command2("tail -n 1 $logdir/$hash{name}.log");

  if ($res) {fail("Could not open log file");}
  
  unless ($out=~/END$/) {fail("$hash{name}: Previous run not finished");}

}

# we now log the start of this test (putting $hash{name} here is redundant)

$snow = stardate();

append_file("$snow $hash{name} START\n", "$logdir/$hash{name}.log");

# finally, we are ready to actually run the test

($out, $err, $res) = cache_command2($hash{cmd});

# report the result

$snow = stardate();

# chomp variables since I add newlines myself

chomp($out, $err, $res);

append_file("OUT: $out\nERR: $err\nRES: $res\n", "$logdir/$hash{name}.log");

$snow = stardate();

append_file("$snow $hash{name} END\n", "$logdir/$hash{name}.log");

# TODO: allow tests to set their own failmsg

if ($res) {fail("failed");}

# if success, wipe out ERR file

write_file("", "$errdir/$hash{name}.err.new");

mv_after_diff("$errdir/$hash{name}.err", "nocmp=1");

sub fail {

  my($str) = @_;

  debug("FAILING:", @_);

  # write to log file and errfile

  append_file("$snow $hash{name} FAIL: $str\n", "$logdir/$hash{name}.log");

  write_file("nagyerass.$hash{name}.$str\n", "$errdir/$hash{name}.err.new");

  mv_after_diff("$errdir/$hash{name}.err", "nocmp=1");

  exit(2);

}

