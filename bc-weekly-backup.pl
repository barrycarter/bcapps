#!/bin/perl

# I make weekly backups of "important" files to a 4G flash drive. Most
# of these are symlinks in /usr/local/etc/weekly-backups/files, but
# some are generated. This program generates the necessary files, and
# then tar/bzip/gpg's them for burning to flash drive

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";
my($dir) = "/usr/local/etc/weekly-backups-files";

# root only, and run at nice level 19
if ($>) {die("Must run as root");}
system("/usr/bin/renice 19 -p $$");

# saving filelists on my machines is very useful, since I'll at least
# know what I've lost
my($tmpfile) = my_tmpfile2();
$str = << "MARK";
ssh $secret{bcpc_user}\@bcpc "/usr/bin/find / -ls" 1> $dir/bcpc-files.txt 2> $dir/bcpc-errs.txt
ssh root\@bcmac "/usr/bin/find / -ls" 1> $dir/bcmac-files.txt 2> $dir/bcmac-errs.txt
/usr/bin/find / -ls 1> $dir/bcunix-files.txt 2> $dir/bcunix-errs.txt
MARK
;

debug($str);
