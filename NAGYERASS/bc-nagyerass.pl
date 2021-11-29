#!/bin/perl

# A parallel nagios-style monitoring script-like thing
# TODO: put in retries for some commands
# TODO: try to fix when something broken?
# TODO: see notes in nagyerass.txt

require "/usr/local/lib/bclib.pl";

# this is testing only, each test in this file is fully qualified

my($tests, $fname) = cmdfile();

while ($tests=~s%<test>(.*?)</test>%%s) {

  my($test) = $1;

  $count++;

  # TODO: not this (use intermediary file?)

  open(A, "|/home/user/BCGIT/NAGYERASS/bc-run-nagyerass-test.pl --debug");
  print A $test;
  close(A);

  write_file($test, "/var/tmp/nagyerass/test-$count.txt");

}

die("END HERE");



#  write_file($test, "/var/tmp/nagyerass

#  debug("TEST: $test");

  # test should not contain $$

#   if ($test=~/\$\$/) {
#     warn("BAD TEST: $test");
#     next;
#   }

#   # for the moment, tests should not contain FUNC either

#   if ($test=~/FUNC/) {
#     warn("BAD TEST: $test");
#     next;
#   }


# #  debug("TEST: $test");

#   for $i (split(/\n/, $test)) {

#     # ignore comments
#     if ($i=~/^\#/) {next;}

#     # TODO: ignoring blank lines though I shoudlnt have to
#     if ($i=~/^\s*$/) {next;}

#     debug("I: $i");
#     unless ($i=~s/^(.*?)\=(.*)$//) {
#       die("BAD LINE: $i");
#     }
#     $hash{$1} = $2;
#   }

#   run_test(\%hash);
# }

=item run_test

Given a hash that looks like a test, run the test, log it, and write
to ~/ERR as necessary

TODO: should also be able to run tests by name

=cut

sub run_test {

  my($hashref) = @_;
  my(%hash) = %$hashref;

  debug("HASH", %hash);



}


# die "TESTING";



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

