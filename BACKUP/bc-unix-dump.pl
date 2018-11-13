#!/bin/perl

# Normalizes the bcunix-dump.sh and similar files for Unix machines
# dumps filelist of given Unix drive and creates other useful-to-me files

# TODO: cross copy TOC across all drives just to make it easier if one
# drive is down (can always get from backups, but not the same)

require "/usr/local/lib/bclib.pl";

# $name is just anything to identify the drive, eg, "bcunix"
my($dir,$name)=(@ARGV);
unless ($dir && $name) {die("Usage: $0 <mountpoint> <name>");}

# if we can't chdir, give up
dodie("chdir('$dir')");

# renice self
system("/usr/bin/renice 19 -p $$");

# timing file
open(A,">$name.log.new")||die("Can't open $name.log.new, $!");
print A "Starting dump: ",time(),"\n";

# ugly hack to avoid //
if ($dir eq "/") {$dir="";}

my($out,$err,$res) = cache_command2("find $dir/ -xdev -noleaf -warn -printf \"%T@ %s %i %m %y %g %u %D %p\n\" >> $name-files.txt.new");

print A "Dump ends: ",time(),"\n";

# move and bzip2 the previous copy
($out,$err,$res) = cache_command2("mv $name-files.txt $name-files.txt.old; bzip2 -f $name-files.txt.old & mv $name-files.txt.new $name-files.txt");

# now create the reverse lookup file for bc-rev-search

print A "Starting rev: ",time(),"\n";

open(B,"$name-files.txt");
open(C,"|sort > $name-files-rev.txt.new");

while (<B>) {
  debug("BETA: $_");
  chomp;
  s%^.*?\/%/%;
  debug("ALPHA: $_");
  # must assign to scalar, grumble
  # and can't even do my($rev) = , because that's list context
  my($rev);
  $rev = reverse();
  debug("REV: $rev");
  print C "$rev\n";
}

close(B);
close(C);

# move and bzip2 for the rev file
($out,$err,$res) = cache_command2("mv $name-files-rev.txt $name-files-rev.txt.old; bzip2 -f $name-files-rev.txt.old & mv $name-files-rev.txt.new $name-files-rev.txt");

print A "Ending rev: ",time(),"\n";

# this is unnecessary, but harmless: create the "converted" version of
# these files for backup purposes

print A "Starting converted: ",time(),"\n";
($out, $err, $res) = cache_command2("$bclib{githome}/BACKUP/bc-format2altformat2.pl $name-files.txt > $name-converted.txt");
print A "Ending converted: ",time(),"\n";

# log file close and move

close(A);

# TODO: consider creating afad.txt (all files all directories here)
# but problem: this proggie doesnt know about other drives, just one its given
# and perhaps just have a single reverse file for bc-rev-search (same prob as above)

# cron job that calls this could do both those things though (unless it backgrounds then no?)

($out,$err,$res) = cache_command2("mv $name.log $name.log.old; bzip2 -f $name.log.old & mv $name.log.new $name.log");
