#!/bin/perl

# Given files on the command line, make sure they are sorted in this
# special way:
# the first field is nondecreasing numerically, but ignore blanks
# first field is exactly 6 digits
# the other fields are irrelevant
# this is surprisingly hard to do using just "sort -c" and variants

require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {
  # perl inside perl = blech?
  $cmd = "echo FILE: $i; egrep -v '^\$' $i | perl -anle 'print \$F[0]' | sort -cn";
  system($cmd);
}
