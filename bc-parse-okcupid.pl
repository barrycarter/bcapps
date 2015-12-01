#!/bin/perl

# Given a list of files containing okcupid profiles, output data for
# those profiles

require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {
  my($all) = read_file($i);

  # just to make things easier to read
  $all=~s/>/>\n/sg;

  debug("ALL: $all");
}
