#!/bin/sh
# This trivial script just runs bc-unix-dump.pl on all my drives
# TODO: automate this if I add new drives etc

# NOTE: running these all at the same time kills the system CPU-wise
# if I happen to be on at that time, so changing these to run
# sequentially, and not in parallel
/home/barrycarter/BCGIT/BACKUP/bc-unix-dump.pl /mnt/extdrive extdrive
/home/barrycarter/BCGIT/BACKUP/bc-unix-dump.pl /mnt/extdrive2 extdrive2
/home/barrycarter/BCGIT/BACKUP/bc-unix-dump.pl /mnt/extdrive3 extdrive3
/home/barrycarter/BCGIT/BACKUP/bc-unix-dump.pl /mnt/extdrive4 extdrive4
/home/barrycarter/BCGIT/BACKUP/bc-unix-dump.pl / bcunix

# bc-unix-dump.pl won't work on /mnt/sshfs, which is HFS+, but I hope
# to convert it over at some point
