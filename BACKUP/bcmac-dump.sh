#!/bin/bash
# to use this:
# ssh root@bcmac "/mnt/sshfs/bcmac-dump.sh > /tmp/bcdump.out &"
# runs on bcmac and creates file dump (what bc-weekly-backup.pl
# currently does but now local)
# NOTE: /mnt/sshfs is a symlink on bcmac (not a true mount), so this DOES work
date > /mnt/sshfs/bcmac-files.txt.new
# note that this intentionally goes into mounted drives (no -xdev)
/usr/bin/find / -print0 | xargs -0 stat -f "%m %z %i %p %g %u %N" >> /mnt/sshfs/bcmac-files.txt.new
date >> /mnt/sshfs/bcmac-files.txt.new
# bzip the previous instance and save it, keep current instance uncompressed
bzip2 -v /mnt/sshfs/bcmac-files.txt
mv /mnt/sshfs/bcmac-files.txt.bz2 /mnt/sshfs/bcmac-files.txt.old.bz2
mv /mnt/sshfs/bcmac-files.txt.new /mnt/sshfs/bcmac-files.txt
perl -nle 's%^.*?\/%/%; print $_' /mnt/sshfs/bcmac-files.txt | rev | sort > /mnt/sshfs/bcmac-files-rev.txt.srt
