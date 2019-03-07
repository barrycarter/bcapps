#!/bin/perl

# version fo bc-waitfile2.pl that waits for a specific file (not
# filemask) to exist and have non-zero size (useful for finding when
# Firefox download complete since Firefox names the file '.part' until
# its downloaded completely)

# --nox: do not send xmessage, just end
# --message: add this to standard message

require "/usr/local/lib/bclib.pl";

my($fname) = @ARGV;
unless ($fname) {die "Usage: $0 filename|glob";}
defaults("message=No message");

# TODO: worry this could hang forever on a file that will never exist
# (but bc-daemon-check should show it?)

while (!(-s $fname)) {sleep 1;}

unless ($globopts{nox}) {
  system("xmessage 'file $fname now exists: $globopts{message}'&");
}
