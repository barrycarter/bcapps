#!/bin/sh
# to use this: /bcunix-dump.sh&
# created for consistency w/ bcmac-dump and bcpc-dump, could do this w/o script
# dumps files and creates a reverse lookup table
cd /
date > bcunix-files.txt.new
find / -xdev -noleaf -warn -printf "%T@ %s %i %m %y %g %u %D %p\n">>bcunix-files.txt.new 2> bcunix-files.err
date >> bcunix-files.txt.new
# bzip the previous instance and save it, keep current instance uncompressed
bzip2 -v bcunix-files.txt
mv bcunix-files.txt.bz2 bcunix-files.txt.old.bz2
mv bcunix-files.txt.new bcunix-files.txt
# TODO: this leaves bcunix-files-rev.txt briefly incomplete
perl -nle 's%^.*?\/%/%; $x=reverse(); print $x' bcunix-files.txt|sort>bcunix-files-rev.txt
# and now the extdrive
# TODO: could do these in parallel actually
cd /mnt/extdrive/
date > extdrive-files.txt.new
find /mnt/extdrive/ -xdev -printf "%T@ %s %i %m %y %g %u %D %p\n">>extdrive-files.txt.new
date >> extdrive-files.txt.new
bzip2 -v extdrive-files.txt
mv extdrive-files.txt.bz2 extdrive-files.txt.old.bz2
mv extdrive-files.txt.new extdrive-files.txt
# TODO: this leaves extdrive-files-rev.txt briefly incomplete
perl -nle 's%^.*?\/%/%; $x=reverse(); print $x' extdrive-files.txt|sort>extdrive-files-rev.txt
