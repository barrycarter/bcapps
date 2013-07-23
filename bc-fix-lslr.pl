#!/bin/perl

# Given the output of ls -laR, output complete filenames

require "/usr/local/lib/bclib.pl";

while (<>) {
  # new directory
  if (m%^(/.*?):$%) {$dir=$1; next;}

  # except as above, only interested in ordinary files
  unless (/^\-/) {next;}

  # kill symlinks (TODO: is this wise?)
#  s/ -> .*$//;

  my(@F) = split(/\s+/,$_);

  # filename starts at $F[8]
  $name = join(" ",@F[8..$#F]);

  # full name of file and remove //
  $fullname = "$dir/$name";
  $fullname=~s%//%/%isg;

  print "$fullname\n";
}
