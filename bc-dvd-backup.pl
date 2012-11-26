#!/bin/perl

# Backs up files to DVD (or other optical media) using tar, bzip, gpg

# Before running this program ($VERSION = date, $ROOT= root of backup)
# Make sure $ROOT/.backup/$VERSION exists
# find $ROOT -type f -printf '%s %T@ ' -exec sha1sum {} ';' > $ROOT/.backup/$VERSION/shafiles.txt &
# sort -k1n -k3 shafiles.txt > ! files0.txt
# In other words, files0.txt contains sha1 and size of files to backup, ordered by filesize, smallest files first, then by sha1sum

require "/usr/local/lib/bclib.pl";

# TODO: allow command line override
$mediasize = 4.4*10**9;
# amount of space Im willing to waste (if necessary)
$waste = .1*$mediasize;
# bzip2 assumed compression (.75 = 25% compression) (if unsure, 1)
$compress = 0.5;

# TODO: hardcoding for testing only
open(A,"/mnt/sshfs/.backup/20121121/files0.txt");
open(B,">/tmp/testing.txt");
open(C,">/tmp/warnings.txt");

while (<A>) {
  chomp;
  unless (m/^(\d+)\s+([\d\.]+)\s+([0-9a-f]{40})\s+(.*)$/i) {
    # TODO: dont die here
    print C "$_\n";
  }

  ($size,$mtime,$sha,$file)=($1,$2,$3,$4);

  # TODO: must backup files0.txt itself, since it notes duplicates
  # if $sha matches lastsha, skip
  if ($sha eq $lastsha) {next;}
  $lastsha = $sha;

  # how many bytes do we have so far
  $bytes += $size;

  # are we over space?
  if ($bytes*$compress >= $mediasize) {
    die "TESTING";
  }

  print B "$file\n";

  debug("SIZE: $size, SHA: $sha, FILE: $file");
}





