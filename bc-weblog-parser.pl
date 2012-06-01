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
  # extract ip
  s/\s+.*$//;

  # add to visits from that IP (not that we really count number of visits)
  $visit4{$_}++;

  # and the "class C" it belongs to
  s/\.\d+$//;

  $visit3{$_}++;
}

@visit4 = sort keys %visit4;
@visit3 = sort keys %visit3;

$num4 = $#visit4+1;
$num3 = $#visit3+1;

print "TOTAL IPs: $num4\nTOTAL 'class C's: $num3\n";
