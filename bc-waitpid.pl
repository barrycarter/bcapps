#!/bin/perl

# Wait until a given process has stopped + then report
# --nox: do not send xmessage, just end
# --message: add this to standard message

require "/usr/local/lib/bclib.pl";

unless ($ARGV[0]) {die "Usage: $0 pid";}

while (!system("ps -p $ARGV[0] > /dev/null")) {sleep 1;}

unless ($globopts{nox}) {system("xmessage '$ARGV[0] is done: $globopts{message}'&");}
