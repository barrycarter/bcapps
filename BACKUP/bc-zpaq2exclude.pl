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

  # 11 digits because `join` requires lexical sort
  my($time) = sprintf("%0.11d", str2time("$date $time UTC"));

  # for `join`, treat extension as separate field (or add null extension)
  unless ($file=~s/\.([^\.\/]*)$/\0$1/) {$file="$file\0";}

  # including $size here is semi-pointless?
  print "$time $file\0$size\n";
}
