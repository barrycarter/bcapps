#!/bin/sh
# This trivial script just runs bc-unix-dump.pl on all my drives
# TODO: automate this if I add new drives etc

# TODO: if I have a drive list somewhere for bc-rev-search, use it
# here as well?

# NOTE: running these all at the same time kills the system CPU-wise
# if I happen to be on at that time, so changing these to run
# sequentially, and not in parallel

# note: some of these drives don't exist, but running bc-unix-dump.pl
# on them is harmless, since it simply creates near empty files in the
# mount directories

# doing root drive first, since others may fail
/home/barrycarter/BCGIT/BACKUP/bc-unix-dump.pl / bcunix

# removing below since its now a symlink
# /home/barrycarter/BCGIT/BACKUP/bc-unix-dump.pl /mnt/extdrive extdrive

# some of these drives no longer exist, but thats ok because their
# mount points are essentially empty

/home/barrycarter/BCGIT/BACKUP/bc-unix-dump.pl /mnt/extdrive2 extdrive2
/home/barrycarter/BCGIT/BACKUP/bc-unix-dump.pl /mnt/extdrive3 extdrive3
/home/barrycarter/BCGIT/BACKUP/bc-unix-dump.pl /mnt/extdrive4 extdrive4
/home/barrycarter/BCGIT/BACKUP/bc-unix-dump.pl /mnt/extdrive5 extdrive5
/home/barrycarter/BCGIT/BACKUP/bc-unix-dump.pl /mnt/extdrive6 extdrive6

# added for kemptown, which is hereby dubbed extdrive7

/home/barrycarter/BCGIT/BACKUP/bc-unix-dump.pl /mnt/extdrive7 extdrive7

# /mnt/extdrive4 later decomissioned
# TODO: find more general way of deciding which drives to "dump"
# /home/barrycarter/BCGIT/BACKUP/bc-unix-dump.pl /mnt/extdrive4 extdrive4

# bc-unix-dump.pl won't work on /mnt/sshfs, which is HFS+, but I hope
# to convert it over at some point
