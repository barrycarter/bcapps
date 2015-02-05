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
my($dir) = "/usr/local/etc/weekly-backups/files";

# root only, and run at nice level 19
if ($>) {die("Must run as root");}
system("/usr/bin/renice 19 -p $$");

# TODO: call subroutines!
# TODO: all subroutines to run in parallel

debug("CALLING dump_ls()");
dump_ls();
debug("CALLING dump_remote()");
dump_remote();
debug("CALLING dump_other()");
dump_other();

# TODO: tar the whole thing up, and encrypt it

# <h>thanks shoeshine boy, you're humble and loveable</h>
debug("ALL FINISHED, SIR");

# dump filelists from all my machines (useful to see what files I'm
# missing in case of disaster recovery)
# subroutinizing this, since it takes forever (and so its nice to test
# without running this each time)
sub dump_ls {

  # for all machine
  system('ssh root\@bcmac "/mnt/sshfs/bcmac-dump.sh > /tmp/bcdump.out &"');
  system('ssh User@bcpc "/cygdrive/c/bcpc-dump.sh > /tmp/bcdump.out &" ');
  system('/bcunix-dump.sh&');
}

# various other things I dumps
sub dump_other {
  local(*A);
  my($str) = << "MARK";
mysqldump --skip-extended-insert=yes test > $dir/bcunix-mysql-test.txt
rpm -qai > $dir/bcunix-rpmqai.txt
yum list > $dir/yumlist.txt
pg_dumpall --host=/var/tmp > $dir/bcunix-pg-backup.txt
MARK
;
  debug("STR: $str");
  open(A,"|parallel -j 10");
  print A $str;
  close(A);
}

# connetions outside my LAN
sub dump_remote {
  local(*A);
  # TODO: keep backup copies(?)
  my($str) = << "MARK";
ssh -i /home/barrycarter/.ssh/id_rsa.bc root\@bcinfo3 'mysqldump --skip-extended-insert=yes wordpress' > $dir/bcinfo3-wordpress.txt
rsync -trlzo -e 'ssh -i /home/barrycarter/.ssh/id_rsa.bc' root\@bcinfo3:/sites/DB/requests.db $dir/bcinfo3-requests.db
rsync "root\@bcmac:/Users/*/*" "root\@bcmac:/Users/*/.*" bcmac/
MARK
;
  debug("STR: $str");
  open(A,"|parallel -j 10");
  print A $str;
  close(A);
}

# TODO: run program at least twice to make sure file overwrites work

# TODO: rename files after checking (new -> cur -> old)
