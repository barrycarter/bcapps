#!/bin/perl

# Given weather data on the STDIN in isd-lite format.txt, find longest
# streak of non-clear weather; see isd-lite-format.txt for format

# NOTE: this can easily be extended to do other things

require "/usr/local/lib/bclib.pl";

my($maxstreak,$curstreak);

while (<>) {
  my(@F) = split(/\s+/, $_);

  my($cov) = $F[9];

  # -9999 = missing, ignored
  if ($cov == -9999) {next;}

  if ($cov>=1 && $cov<=19) {$curstreak++; next;}

  unless ($cov == 0) {die("SKY COVERAGE INVALID: $_");}

  # at this point coverage is 0, is this new maxstreak?
  debug("CURSTREAK: $curstreak");

  # if not new max, just rest counter and first line
  if ($curstreak < $maxstreak) {$curstreak = 0; $firstline = $_; next;}

  # this is new maxstreak
  debug("ALPHA, CURSTREAK: $curstreak");
  $maxline = $_;
  $maxfirst = $firstline;
  $maxstreak = $curstreak;
  $curstreak = 0;
  debug("ALPHA, maxstreak: $maxstreak");
}

print "STREAK:\n$maxfirst\n$maxstreak\nENDS: $maxline\n";


