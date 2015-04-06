#!/bin/perl

# Given the output of "zpaq list", outputs data that can be used to
# exclude these files from next backup (via mtime and filename)

require "/usr/local/lib/bclib.pl";

while (<>) {
  chomp;
  my($symb, $date, $time, $size, $mode, $file) = split(/\s+/,$_,6);

  # ignroe directories
  if ($mode=~/^d/) {next;}

  unless ($symb eq "-") {warn("SKIPPING: $_"); next;}

  # strip directory head (where I rsync stuff)
  unless ($file=~s%^ROOT/%/%) {warn "BAD FILENAME: $file";}

  # want to sort by time descending, see bc-format2altformat.pl for details
  my($time) = 2**33-str2time("$date $time UTC");

  # the only important extension for backups is tar (others are removed)
  if ($file=~s/\.tar$//) {$file="$file\0tar";} else {$file="$file\0";}

  # including $size here is semi-pointless?
  print "$time $file\0$size\n";
}
