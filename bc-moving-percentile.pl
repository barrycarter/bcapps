#!/bin/perl -l

# Given a series of data, find the "moving percentile" of the first element
require "/usr/local/lib/bclib.pl";

$val = <>;

while (<>) {
  $pos{$_<=>$val}++;
  # doesn't work sans $pile= below due to weird division rules?
  print $pile=($pos{-1}+$pos{0}/2)/($pos{-1}+$pos{0}+$pos{1});
}

