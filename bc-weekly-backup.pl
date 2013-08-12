#!/bin/perl

# I make weekly backups of "important" files to a 4G flash drive. Most
# of these are symlinks in /usr/local/etc/weekly-backups/files, but
# some are generated. This program generates the necessary files, and
# then tar/bzip/gpg's them for burning to flash drive

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";
my($dir) = "/usr/local/etc/weekly-backups/files";

# root only, and run at nice level 19
if ($>) {die("Must run as root");}
system("/usr/bin/renice 19 -p $$");

# TODO: call subroutines!
# TODO: all subroutines to run in parallel

dump_ls();
dump_other();
dump_remote();

# dump filelists from all my machines (useful to see what files I'm
# missing in case of disaster recovery)
# subroutinizing this, since it takes forever (and so its nice to test
# without running this each time)
sub dump_ls {
  # TODO: run these safer so I don't autoclobber existing versions
  # generate file lists from all machines (in parallel)
  local(*A);
  # on bcpc and bcmac, I *do* want to descend into other devices
  my($str) = << "MARK";
(ssh $secret{bcpc_user}\@bcpc "/usr/bin/find / -ls" > $dir/bcpc-files.txt) >&! $dir/bcpc-errs.txt; bzip2 -f -v $dir/bcpc-files.txt
(ssh root\@bcmac "/usr/bin/find / -ls" > $dir/bcmac-files.txt) >&! $dir/bcmac-errs.txt; bzip2 -f -v $dir/bcmac-files.txt
(/usr/bin/find / -xdev -ls > $dir/bcunix-files.txt) >&! $dir/bcunix-errs.txt; bzip2 -f -v $dir/bcunix-files.txt
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
mysqldump test > $dir/bcunix-mysql-test.txt; bzip2 -v -f $dir/bcunix-mysql-test.txt
rpm -qai > $dir/bcunix-rpmqai.txt; bzip2 -v -f $dir/bcunix-rpmqai.txt
yum list > $dir/yumlist.txt ; bzip2 -v -f $dir/yumlist.txt
pg_dumpall --host=/var/tmp > $dir/bcunix-pg-backup.txt; bzip2 -v -f $dir/bcunix-pg-backup.txt
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
  my($str) = << "MARK";
ssh -i /home/barrycarter/.ssh/id_rsa.bc root\@bcinfonew 'mysqldump wordpress' > $dir/bcinfonew-wordpress.txt; bzip2 -v -f $dir/bcinfonew-wordpress.txt
ssh -i /home/barrycarter/.ssh/id_rsa.bc root\@bcinfo3 'mysqldump wordpress' > $dir/bcinfo3-wordpress.txt; bzip2 -v -f $dir/bcinfo3-wordpress.txt
rsync -vtrlzo -e 'ssh -i /home/barrycarter/.ssh/id_rsa.bc' root\@bcinfonew:/usr/share/wordpress root\@bcinfonew:/sites/DB/requests.db $dir/
rsync -v "root\@bcmac:/Users/*/*" "root\@bcmac:/Users/*/.*" bcmac/
MARK
;
  debug("STR: $str");
  open(A,"|parallel -j 10");
  print A $str;
  close(A);
}

# TODO: run program at least twice to make sure file overwrites work

# TODO: rename files after checking (new -> cur -> old)

# TODO: bzip2 file dumps locally (because I have limited space), even
# though the final tar will bzip anyway
