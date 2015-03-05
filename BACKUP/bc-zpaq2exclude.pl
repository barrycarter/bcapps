#!/bin/perl

# Given the output of "zpaq list", outputs data that can be used to
# exclude these files from next backup (via mtime, size and filename)

require "/usr/local/lib/bclib.pl";

while (<>) {
  my($symb, $date, $time, $size, $mode, $file) = split(/\s+/,$_,6);

  # ignroe directories
  if ($mode=~/^d/) {next;}

  # strip directory head (where I rsync stuff)
  $file=~s%/mnt/sshfs/CORPUS/ROOT/%/%;

  unless ($symb eq "-") {
    warn("SKIPPING: $_");
    next;
  }

  # 10 digits because comm requires lexical sort
  my($time) = sprintf("%0.10d", str2time("$date $time UTC"));
  print "$time $size $file";
}
