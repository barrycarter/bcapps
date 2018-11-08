#!/bin/perl

# Given a list of words on the stdin, bin them so that the Levenshtein
# distance between any two in the bin is the length of the words in
# the bin (ie, maximal)

require "/usr/local/lib/bclib.pl";

my(@words);

while (<>) {chomp; push(@words, $_);}

# find number of compatible words for each word

# TODO: this could be done twice as fast

for $i (@words) {
  for $j (@words) {
    debug("$i, $j");
  }
}

