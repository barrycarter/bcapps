#!/bin/perl

# attempts to read MobiPocket files (ie, where Kindle keeps your
# clippings and notes on a book?)

require "/usr/local/lib/bclib.pl";

($all, $fname) = cmdfile();

# split into DATA chunks
my(@data) = split(/DATA./,$all);

for $i (@data) {
  # remove nulls (must happen before removing other things)
  $i=~s/\0//isg;
  # tabs to spaces
#  $i=~s/\x11/ /isg;
  # remove nonprintables (incl nulls)
  $i=~s/[\x00-\x1F\x81-\xFF]/ /isg;
  
  debug("I: $i");
}

