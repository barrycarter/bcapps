#!/bin/perl

# Given the HTML in a quora log entry like
# https://www.quora.com/log/revision/144239526, extract date and text

require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {
  my($all) = `bzcat $i`;

  debug("ALL: $all");
}

