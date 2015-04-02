#!/bin/perl

# parses data obtained from tcpflow'ing bc-bernco-prop-dl.pl

require "/usr/local/lib/bclib.pl";

while (<>) {
  my(%hash);

  # this marks the start of a record
  if (/address are updated weekly through September 2014/) {%hash=();}

  debug("READING: $_");
}

