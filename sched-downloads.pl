#!/bin/perl

# Given a list of myaccounts (currently in ~/myaccounts.txt, but uses
# STDIN), create a download schedule, one per day

# note that randomization is intentionally one time only
# My usage: grep -v '^#' ~/myaccounts.txt | sort -R | sched-downloads.pl

require "/usr/local/lib/bclib.pl";

my(@accts);

while (<>) {chomp; push(@accts,$_);}
my($now) = time();

debug(@accts);
my($date);

do {
  $date = strftime("%Y%m%d", localtime($now+86400*$i++));
  debug("DATE: $date, ARRAY IND:", $accts[$i%(scalar @accts)]);
  print "$date dl $accts[$i%(scalar @accts)]\n";
} while ($date < 20300000);



