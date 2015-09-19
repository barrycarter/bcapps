#!/bin/sh
# for extdrive1 (which is just extdrive)
cd /mnt/extdrive/
date > extdrive-files.txt.new
find /mnt/extdrive/ -xdev -printf "%T@ %s %i %m %y %g %u %D %p\n">>extdrive-files.txt.new
date >> extdrive-files.txt.new
bzip2 -v extdrive-files.txt
mv extdrive-files.txt.bz2 extdrive-files.txt.old.bz2
mv extdrive-files.txt.new extdrive-files.txt
# TODO: this leaves extdrive-files-rev.txt briefly incomplete
perl -nle 's%^.*?\/%/%; $x=reverse(); print $x' extdrive-files.txt|sort>extdrive-files-rev.txt
