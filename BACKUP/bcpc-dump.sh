#!/usr/bin/sh
# to use this:
# ssh User@bcpc "/cygdrive/c/bcpc-dump.sh > /tmp/bcdump.out &"
# dumps files and creates a reverse lookup table
cd /cygdrive/c
date > bcpc-files.txt.new
# the /bin below is required, otherwise uses window's find
/bin/find /cygdrive/ -print0|xargs -0 stat -c "%s %Y %i %f %g %u %n">>bcpc-files.txt.new
date >> bcpc-files.txt.new
# bzip the previous instance and save it, keep current instance uncompressed
bzip2 -v bcpc-files.txt
mv bcpc-files.txt.bz2 bcpc-files.txt.old.bz2
mv bcpc-files.txt.new bcpc-files.txt
# TODO: this leaves bcpc-files-rev.txt briefly incomplete
# env change below required for consistent sorting
# rev chokes on multibyte chars; the Perl oddness below works, but is weird
perl -nle 's%^.*?\/%/%; $x=reverse(); print $x' bcpc-files.txt| env LC_ALL=C sort> bcpc-files-rev.txt.srt
