# this batch file runs on bcpc and creates a file dump (plus other
# things) with a backup, so is never out of date while running the
# dump (pretty much what bc-weekly-backup.pl was doing, but now local)
/usr/bin/date > /cygdrive/c/bcpc-files.txt.new
/usr/bin/find / -ls >> /cygdrive/c/bcpc-files.txt.new
echo EOF >> /cygdrive/c/bcpc-files.txt.new
mv /cygdrive/c/bcpc-files.txt.bz2 /cygdrive/c/bcpc-files.txt.old.bz2
mv /cygdrive/c/bcpc-files.txt.new /cygdrive/c/bcpc-files.txt
bzip2 -f -v /cygdrive/c/bcpc-files.txt
