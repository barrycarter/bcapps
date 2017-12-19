#!/bin/perl

# Given the output of "sha1sum <files>", copy the file to
# /mnt/lobos/FILESBYSHA1 (TODO: genercize this directory) as its
# sha1sum (with two levels of subdirectory)

require "/usr/local/lib/bclib.pl";

# TODO: ignore bad file names
# TODO: check for full path names

while (<>) {

  # the \s+ below *won't* miss files with a leading space since I
  # require full path names

  unless (m%([0-9a-f]{40})\s+(/.*?)$%) {
    warn "BAD LINE: $_";
    next;
  }

  my($sha, $file) = ($1, $2);

  # two level dir path by sha1
  
  my($dir1) = substr($sha, 0, 2);
  my($dir2) = substr($sha, 2, 2);

  debug("$dir1/$dir2/$sha");



}

