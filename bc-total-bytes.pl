#!/bin/perl

require "/usr/local/lib/bclib.pl";

# Given the (possibly filtered) output of "find [...] -ls", find the
# total space used for each file (already given) and each directory,
# including parent directories

# NOTE: could've sworn I've written something very similar to this already

my(%size);

while (<>) {

  # cleanup
  s/^\s*(.*?)\s*$/$1/;

  my(@data) = split(/\s+/, $_);
  my($size) = $data[6];

  # this assumes filenames are split by single spaces = bad?
  my($file) = join(" ",@data[10..$#data]);

  # find all ancestor directories
  do {$size{$file} += $size;} while ($file=~s/\/([^\/]*?)$//);
}

for $i (sort {$size{$b} <=> $size{$a}} keys %size) {print "$i $size{$i}\n";}

