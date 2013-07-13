#!/bin/perl

# Given the output of ls -laR, output complete filenames

require "/usr/local/lib/bclib.pl";

while (<>) {
  # new directory
  if (/^(.*?):$/) {$dir=$1; next;}

  # total count (ignore)
  if (/^total/) {next;}

  # kill symlinks (TODO: is this wise?)
  s/ -> .*$//;

  my(@F) = split(/\s+/,$_);

  # filename starts at $F[8]
  $name = join(" ",@F[8..$#F]);

  debug("THUNK: $_","$dir/$name");
#  print "$dir/$name\n";
}
