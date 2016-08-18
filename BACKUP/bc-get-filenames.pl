#!/bin/perl

# Given a list of files in the format specified by README, extract
# just the filenames, potentially trimming them
# --trim=str: trim str from the start (only) of filenames

require "/usr/local/lib/bclib.pl";

while (<>) {

  my(@list) = split(/\s+/, $_, 9);

  $list[8]=~s/^$globopts{trim}//;

  print $list[8];

}
