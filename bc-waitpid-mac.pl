#!/bin/perl

# Wait until a given process has stopped + then report

# This version for mac does NOT require bclib.pl (which I can't get
# working because "cpan Astro::Nova" fails for some reason on mac)

unless ($ARGV[0]) {die "Usage: $0 pid";}
while (!system("ps -p $ARGV[0] > /dev/null")) {sleep 1;}
