#!/bin/perl

# A parallel nagios-style monitoring script-like thing
# TODO: put in retries for some commands
# TODO: try to fix when something broken?
# TODO: see notes in nagyerass.txt

require "bclib.pl";

$tests = read_file("nagyerass.txt");

chdir(tmpdir());

for $i (split(/\n/,$tests)) {
  # ignore blanks/comments
  if ($i=~/^\#/ || $i=~/^\s*$/) {next;}

  # wrap 'er up
  $n++;
  $test = "($i) 1> $n.out 2> $n.err; echo \$? > $n.res";
  write_file($test, "$n.cmd");
  push(@tests,$test);
}

write_file(join("\n",@tests), "tests");
system("parallel < tests > parout.txt");
