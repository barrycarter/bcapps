# runs on bcmac and creates file dump (what bc-weekly-backup.pl
# currently does but now local)
date > /mnt/sshfs/bcmac-files.txt.new
/usr/bin/find / -ls >> /mnt/sshfs/bcmac-files.txt.new
echo EOF >> /mnt/sshfs/bcmac-files.txt.new
mv /mnt/sshfs/bcmac-files.txt.bz2 /mnt/sshfs/bcmac-files.txt.old.bz2
mv /mnt/sshfs/bcmac-files.txt.new /mnt/sshfs/bcmac-files.txt
bzip2 -f -v /mnt/sshfs/bcmac-files.txt
