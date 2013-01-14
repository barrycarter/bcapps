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
  # remove first char (always bogus)
  $i=~s/^.//isg;
  # all else to spaces
  $i=~s/[^ -~]/ /isg;
  # collapse spaces
  $i=~s/\s+/ /isg;
  $i = trim($i);
  # anything after BKMK is garbage
  $i=~s/BKMK4.*?$//isg;

  # EBVS = internal use, not to print
  if ($i=~/EBAR EBVS/ || $i=~/PARMOBI/) {next;}

  print "$i\n";
}

