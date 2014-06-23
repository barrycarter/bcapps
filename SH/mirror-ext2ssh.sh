echo mirroring /mnt/extdrive to /mnt/sshfs excluding .recoll

sudo rsync -Pzrlpt --exclude=".recoll/" /mnt/extdrive/ /mnt/sshfs 1> /tmp/extdrive-rsync.out 2> /tmp/extdrive-rsync.err

