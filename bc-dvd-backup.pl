#!/bin/perl

# Backs up files to DVD (or other optical media) using tar, bzip, gpg

# Before running this program ($VERSION = date, $ROOT= root of backup)
# Make sure $ROOT/.backup/$VERSION exists
# find $ROOT -type f -printf '%s %T@ ' -exec sha1sum {} ';' > $ROOT/.backup/$VERSION/shafiles.txt &
# sort -n shafiles.txt > files0.txt
# maybe: sort -k1n -k3 shafiles.txt > ! files0.txt
# TODO: must do secondary sort by sha1sum
# In other words, files0.txt contains sha1 and size of files to backup, ordered by filesize, smallest files first

require "/usr/local/lib/bclib.pl";


