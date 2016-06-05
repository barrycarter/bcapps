#!/bin/perl

# Clone of bc-waitpid.pl
# Wait until a fileglob exists + then report
# --nox: do not send xmessage, just end
# --message: add this to standard message

# TODO: UGH, globbing something with no special chars yields the thing
# regardless of whether it exists

require "/usr/local/lib/bclib.pl";

my($fname) = @ARGV;
unless ($fname) {die "Usage: $0 filename|glob";}
defaults("message=No message");

# TODO: worry this could hang forever on a file that will never exist (but bc-daemon-check should show it?)

while (!(glob $fname)) {sleep 5;}

unless ($globopts{nox}) {system("xmessage 'file $fname now exists: $globopts{message}'&");}
