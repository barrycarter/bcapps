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
debug("CALLING dump_other()");
dump_other();
debug("CALLING dump_remote()");
dump_remote();

# TODO: tar the whole thing up, and encrypt it

# <h>thanks shoeshine boy, you're humble and loveable</h>
debug("ALL FINISHED, SIR");

# dump filelists from all my machines (useful to see what files I'm
# missing in case of disaster recovery)
# subroutinizing this, since it takes forever (and so its nice to test
# without running this each time)
sub dump_ls {
  # below just for reading purposes, cleaned up and run later
  my($bcpc_cmd) = << "MARK";
echo SOF > /cygdrive/c/bcpc-files.txt.new
date >> /cygdrive/c/bcpc-files.txt.new
/usr/bin/find / -ls >> /cygdrive/c/bcpc-files.txt.new
date >> /cygdrive/c/bcpc-files.txt.new
echo EOF >> /cygdrive/c/bcpc-files.txt.new
mv /cygdrive/c/bcpc-files.txt /cygdrive/c/bcpc-files.txt.old
mv /cygdrive/c/bcpc-files.txt.new /cygdrive/c/bcpc-files.txt
MARK
;

  my($bcmac_cmd) = << "MARK";
echo SOF > /mnt/sshfs/bcmac-files.txt.new
date >> /mnt/sshfs/bcmac-files.txt.new
/usr/bin/find / -ls >> /mnt/sshfs/bcmac-files.txt.new
date >> /mnt/sshfs/bcmac-files.txt.new
echo EOF >> /mnt/sshfs/bcmac-files.txt.new
mv /mnt/sshfs/bcmac-files.txt /mnt/sshfs/bcmac-files.txt.old
mv /mnt/sshfs/bcmac-files.txt.new /mnt/sshfs/bcmac-files.txt
MARK
;

  my($bcunix_cmd) = << "MARK";
echo SOF > $dir/bcunix-files.txt.new
date >> $dir/bcunix-files.txt.new
/usr/bin/find / -xdev -ls >> $dir/bcunix-files.txt.new
date >> $dir/bcunix-files.txt.new
echo EOF >> $dir/bcunix-files.txt.new
mv $dir/bcunix-files.txt $dir/bcunix-files.txt.old
mv $dir/bcunix-files.txt.new $dir/bcunix-files.txt
MARK
;


  $bcpc_cmd=~s/\n/; /isg;
  $bcmac_cmd=~s/\n/; /isg;
  $bcunix_cmd=~s/\n/; /isg;

  # TODO: run these safer so I don't autoclobber existing versions
  # generate file lists from all machines (in parallel)
  local(*A);
  # on bcpc and bcmac, I *do* want to descend into other devices
  warn "NOT STORING LS LOCALLY!";
  # TODO: hardcoding here is bad
  my($str) = << "MARK";
ssh $secret{bcpc_user}\@bcpc "$bcpc_cmd" >&! $dir/bcpc-errs.txt;
ssh root\@bcmac "$bcmac_cmd" >&! $dir/bcmac-errs.txt;
$bcunix_cmd
MARK
;
  debug("STR: $str");
  open(A,"|parallel -j 10");
  print A $str;
  close(A);
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
  # TODO: update below when I start using bcinfo3
  # TODO: keep backup copies
  my($str) = << "MARK";
ssh -i /home/barrycarter/.ssh/id_rsa.bc root\@bcinfonew 'mysqldump --skip-extended-insert=yes wordpress' > $dir/bcinfonew-wordpress.txt
ssh -i /home/barrycarter/.ssh/id_rsa.bc root\@bcinfo3 'mysqldump --skip-extended-insert=yes wordpress' > $dir/bcinfo3-wordpress.txt
rsync -trlzo -e 'ssh -i /home/barrycarter/.ssh/id_rsa.bc' root\@bcinfonew:/usr/share/wordpress root\@bcinfonew:/sites/DB/requests.db $dir/
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
