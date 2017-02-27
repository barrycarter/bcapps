#!/bin/perl

# Determines which files have changed on brighton (in user and root
# dirs only) since the dullon-root rsync over by normalizing filelists

# NOTE: post-processing steps required, not done here

# grabs mtime/size/filename

require "/usr/local/lib/bclib.pl";

while (<>) {
  chomp;

  my(@list) = split(/\s+/, $_, 9);

  # ignore dirs/links
  if ($list[4]=~/^[dl]$/) {next;}

  print "$list[0] $list[1] $list[-1]\n";
}

