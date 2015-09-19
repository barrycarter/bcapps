#!/bin/sh
# for extdrive2
cd /mnt/extdrive2/
date > extdrive2-files.txt.new
find /mnt/extdrive2/ -xdev -printf "%T@ %s %i %m %y %g %u %D %p\n">>extdrive2-files.txt.new
date >> extdrive2-files.txt.new
bzip2 -v extdrive2-files.txt
mv extdrive2-files.txt.bz2 extdrive2-files.txt.old.bz2
mv extdrive2-files.txt.new extdrive2-files.txt
# TODO: this leaves extdrive-files-rev.txt briefly incomplete
perl -nle 's%^.*?\/%/%; $x=reverse(); print $x' extdrive2-files.txt|sort>extdrive2-files-rev.txt
