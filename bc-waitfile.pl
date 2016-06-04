#!/bin/perl

# Clone of bc-waitpid.pl
# Wait until a file exists + then report
# --nox: do not send xmessage, just end
# --message: add this to standard message

require "/usr/local/lib/bclib.pl";

my($fname) = @ARGV;
unless ($fname) {die "Usage: $0 pid|string";}
defaults("message=No message");

# TODO: worry this could hang forever on a file that will never exist (but bc-daemon-check should show it?)

while (!(-f $fname)) {sleep 5;}

unless ($globopts{nox}) {system("xmessage 'file $fname now exists: $globopts{message}'&");}
