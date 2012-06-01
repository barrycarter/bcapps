#!/bin/perl

# attempts to get a truer idea of how many "hits" my pages get by:
# filtering out bots
# counting each IP (not each page) as a visit
# optionally treating IPs in the same class C as one user

require "/usr/local/lib/bclib.pl";

# can't seem to create a pipe that allows comments in -f files, so...
chdir(tmpdir());
system("egrep -v '^#|^ *\$' /home/barrycarter/BCGIT/bots.txt > phrases.txt");
# TODO: allow multiple arguments, and don't assume .gz
open(A, "zfgrep -ivf phrases.txt $ARGV[0]|");

while (<A>) {
  debug("THUNK: $_");
}
