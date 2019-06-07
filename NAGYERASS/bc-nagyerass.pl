#!/bin/perl

# A parallel nagios-style monitoring script-like thing
# TODO: put in retries for some commands
# TODO: try to fix when something broken?
# TODO: see notes in nagyerass.txt

require "/usr/local/lib/bclib.pl";

parse_nagyerass_cfg(read_file("nagyerass.cfg"));


=item parse_nagyerass_cfg

Parses the given string (which is the contents of one or more files)
and writes to /usr/local/etc/nagyerass individual tests (and
timestamps if needed), while checking for duplicate test names, etc

=cut

sub parse_nagyerass_cfg {

  my($cfg) = @_;

  while ($cfg=~s%<test>(.*?)</test>%%s) {
    my($test) = $1;
    debug("TEST: $test");
  }
}

die "TESTING";

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

for $i (1..$n) {
  debug("TEST: $tests[$i-1]", "OUT:", read_file("$i.out"), "ERR:",
	read_file("$i.err"), "RES:",  read_file("$i.res"));
}

