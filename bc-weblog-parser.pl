#!/bin/perl

# attempts to get a truer idea of how many "hits" my pages get by:
# filtering out bots
# counting each IP (not each page) as a visit
# optionally treating IPs in the same class C as one user

require "/usr/local/lib/bclib.pl";

# TODO: allow multiple arguments, and don't assume .gz
$cmd = "egrep -v '^#|^ *\$' /home/barrycarter/BCGIT/bots.txt | zfgrep -ivf- $ARGV[0]";
debug("CMD: $cmd");
open(A,"$cmd|");
# open(A,"$cmd /home/barrycarter/BCGIT/bots.txt|");
# system("$cmd /home/barrycarter/BCGIT/bots.txt");
# open(A,"egrep -v '^#|^ *\$' /home/barrycarter/BCGIT/bots.txt |");

while (<A>) {
  debug("THUNK: $_");
}
