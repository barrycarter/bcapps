#!/bin/perl

# I make weekly backups of "important" files to a 4G flash drive. Most
# of these are symlinks in /usr/local/etc/weekly-backups/files, but
# some are generated. This program generates the necessary files, and
# then tar/gpg's them for burning to flash drive

# removing bzip of ls dumps because:
# 1. interferes with overwriting [I could fix this]
# 2. i have enough room to store them uncompressed
# 3. i use them often enough that it's efficient to have them uncompressed
# 4. saves time and CPU, making this proggie more efficient

# as of 10 Jan 2015, putting bcunix file dumps in root dir

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";
my($dir) = "/usr/local/etc/backups";

# root only, and run at nice level 19
if ($>) {die("Must run as root");}
system("/usr/bin/renice 19 -p $$");

# TODO: call subroutines!
# TODO: all subroutines to run in parallel

debug("CALLING dump_remote()");
dump_remote();
debug("CALLING dump_other()");
dump_other();

# TODO: tar the whole thing up, and encrypt it

# <h>thanks shoeshine boy, you're humble and loveable</h>
debug("ALL FINISHED, SIR");

# various other things I dumps
sub dump_other {
  local(*A);
  # TODO: test that these commands work, they sometimes appear to dump out small files, perhaps due to errors
  my($str) = << "MARK";
mysqldump --skip-extended-insert=yes test > $dir/bcunix-mysql-test.txt.new; mv -f $dir/bcunix-mysql-test.txt $dir/bcunix-mysql-test.txt.old; mv -f $dir/bcunix-mysql-test.txt.new $dir/bcunix-mysql-test.txt
rpm -qai > $dir/bcunix-rpmqai.txt.new; mv -f $dir/bcunix-rpmqai.txt $dir/bcunix-rpmqai.txt.old;  mv -f $dir/bcunix-rpmqai.txt.new $dir/bcunix-rpmqai.txt
yum list > $dir/yumlist.txt.new; mv -f yumlist.txt yumlist.txt.old; mv -f yumlist.txt.new yumlist.txt
pg_dumpall --host=/var/tmp > $dir/bcunix-pg-backup.txt.new; mv -f $dir/bcunix-pg-backup.txt $dir/bcunix-pg-backup.txt.old; mv -f $dir/bcunix-pg-backup.txt.new $dir/bcunix-pg-backup.txt
MARK
;
  debug("STR: $str");
  # TODO: this is broken, I can't mv while dumping, at least not safely
  open(A,"|parallel -j 10");
  print A $str;
  close(A);
}

# connetions outside my LAN
sub dump_remote {
  local(*A);
  # TODO: keep backup copies(?)
  my($str) = << "MARK";
ssh -i /home/barrycarter/.ssh/id_rsa.bc root\@bcinfo3 'mysqldump --skip-extended-insert=yes --databases wordpress requests' > $dir/bcinfo3-wordpress-requests.txt.new; mv -f $dir/bcinfo3-wordpress-requests.txt $dir/bcinfo3-wordpress-requests.txt.old;  mv -f $dir/bcinfo3-wordpress-requests.txt.new $dir/bcinfo3-wordpress-requests.txt
rsync -trlzo -e 'ssh -i /home/barrycarter/.ssh/id_rsa.bc' root\@bcinfo3:/sites/DB/requests.db $dir/bcinfo3-requests.db
rsync -trlzo -e 'ssh -i /home/barrycarter/.ssh/id_rsa.bc' root\@bcinfo3:/sites/DB/gocomics-dump.txt.bz2 $dir/bcinfo3-gocomics-dump.txt.bz2
# rsync "root\@bcmac:/Users/*/*" "root\@bcmac:/Users/*/.*" bcmac/
MARK
;
  debug("STR: $str");
  open(A,"|parallel -j 10");
  print A $str;
  close(A);
}

# TODO: run program at least twice to make sure file overwrites work

# TODO: rename files after checking (new -> cur -> old)
