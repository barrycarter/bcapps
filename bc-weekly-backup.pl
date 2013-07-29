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

# dump filelists from all my machines (useful to see what files I'm
# missing in case of disaster recovery)
sub dump_ls {
  # generate file lists from all machines (in parallel)
  $str = << "MARK";
(ssh $secret{bcpc_user}\@bcpc "/usr/bin/find / -ls" > $dir/bcpc-files.txt.new) >& $dir/bcpc-errs.txt
(ssh root\@bcmac "/usr/bin/find / -ls" > $dir/bcmac-files.txt.new) >& $dir/bcmac-errs.txt
(/usr/bin/find / -ls > $dir/bcunix-files.txt.new) >& $dir/bcunix-errs.txt
MARK
;
  debug("STR: $str");
  open(A,"|parallel");
  print A $str;
  close(A);

  # TODO: add sanity check here; if .new files are too small they are probably bad
  for $i ("bcpc","bcmac","bcunix") {
    system("mv $dir/bcpc-files.txt $dir/bcpc-files.txt.old; mv $dir/bcpc-files.txt.new $dir/bcpc-files.txt");
  }
}

# TODO: run program at least twice to make sure file overwrites work

# TODO: rename files after checking (new -> cur -> old)

# TODO: bzip2 file dumps locally (because I have limited space), even
# though the final tar will bzip anyway
