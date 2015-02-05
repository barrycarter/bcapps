#!/bin/sh
# to use this: /bcunix-dump.sh&
# created for consistency w/ bcmac-dump and bcpc-dump, could do this w/o script
# dumps files and creates a reverse lookup table
cd /
date > bcunix-files.txt.new
# the /bin below is required, otherwise uses window's find
# trying this sans -xdev, may be a bad idea
find / -print0|xargs -0 stat -c "%s %Y %i %f %g %u %n">>bcunix-files.txt.new
date >> bcunix-files.txt.new
# bzip the previous instance and save it, keep current instance uncompressed
bzip2 -v bcunix-files.txt
mv bcunix-files.txt.bz2 bcunix-files.txt.old.bz2
mv bcunix-files.txt.new bcunix-files.txt
# TODO: this leaves bcunix-files-rev.txt briefly incomplete
perl -nle 's%^.*?\/%/%; print $_' bcunix-files.txt|rev|sort>bcunix-files-rev.txt
