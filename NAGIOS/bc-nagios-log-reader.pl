#!/bin/perl

# Trivial nagios log reader, just changes [time] to more readable time

# could've sworn I've written this before

use POSIX;

while (<>) {
  s/^\[(\d+)\]/strftime("[%Y%m%d.%H%M%S]", localtime($1))/e;
  print $_;
}

