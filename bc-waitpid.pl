#!/bin/perl

# Wait until a given process has stopped + then report

unless ($ARGV[0]) {die "Usage: $0 pid";}
while (-d "/proc/$ARGV[0]") {sleep 1;}

system("xmessage $ARGV[0] is done&");
