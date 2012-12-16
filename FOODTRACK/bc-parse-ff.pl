#!/bin/perl

# parses foodfacts.com data

require "/usr/local/lib/bclib.pl";

# this file contains output of:
# fgrep -liR 'upc code:' . | tee fileswithupc.txt
@upc = split(/\n/, read_file("/mnt/sshfs/FF/fileswithupc.txt"));

for $i (@upc) {

  # convert to absolute path
  $i=~s%^\.%/mnt/sshfs/FF%;
  debug("FILE: $i");

  # read file
  $data = read_file($i);

  # much of info is in form "<span class="nutri-left">(.*?)</span>"
  @info = ();
  while ($data=~s%<span class="nutri-left">(.*?)</span>%%s) {
    push(@info,$1);
  }

  debug("INFO",@info);
}
