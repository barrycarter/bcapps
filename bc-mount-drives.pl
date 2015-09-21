#!/bin/perl

# another script only I can use (sort of), this remounts my drives
# using blkid, after I've had to reset the USB bus (which unmounts
# everything implicitly)

require "/usr/local/lib/bclib.pl";

my(%drive);

# read the blkids.txt file (private) of my drives
for $i (split(/\n/,read_file("$bclib{home}/blkids.txt"))) {
  if ($i=~/^\#/) {next;}
  $i=~/^(.*?)\s+(.*)$/||die("BAD LINE: $i");
  $drive{$1}=$2;
}

debug(%drive);

my($out,$err,$res) = cache_command2("blkid");

debug("OUT: $out");
