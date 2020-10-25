#!/bin/perl

# stop a list of processes using pkill which works better than killall
# in terms of matching

require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {
  print "sudo pkill -STOP $i\n";
}

