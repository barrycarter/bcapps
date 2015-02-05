#!/bin/sh
# to use this:
# ssh root@bcmac "/mnt/sshfs/bcmac-dump.sh > /tmp/bcdump.out &"
# runs on bcmac and creates file dump (what bc-weekly-backup.pl
# currently does but now local)
# NOTE: /mnt/sshfs is a symlink on bcmac (not a true mount), so this DOES work
date > /mnt/sshfs/bcmac-files.txt.new
# note that this intentionally goes into mounted drives (no -xdev)
# below is size, mod time, type, inode, perms, user group, name
# Mac OS X stat doesn't do `filename' so triple quoting instead
/usr/bin/find / -print0 | xargs -0 stat -f "%z %m '%HT' %i %p %u %g '''%N'''" >> /mnt/sshfs/bcmac-files.txt.new
date >> /mnt/sshfs/bcmac-files.txt.new 
mv /mnt/sshfs/bcmac-files.txt.bz2 /mnt/sshfs/bcmac-files.txt.old.bz2
mv /mnt/sshfs/bcmac-files.txt.new /mnt/sshfs/bcmac-files.txt
perl -nle 's%^.*?\/%/%; print $_' /mnt/sshfs/bcmac-files.txt | rev | sort > /mnt/sshfs/bcmac-files-rev.txt
bzip2 -f -v /mnt/sshfs/bcmac-files.txt
