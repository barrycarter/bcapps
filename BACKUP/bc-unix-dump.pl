#!/bin/perl

# Normalizes the bcunix-dump.sh and similar files for Unix machines
# dumps filelist of given Unix drive and creates other useful-to-me files

require "/usr/local/lib/bclib.pl";

# $name is just anything to identify the drive, eg, "bcunix"
my($dir,$name)=(@ARGV);
unless ($dir && $name) {die("Usage: $0 <mountpoint> <name>");}

# if we can't chdir, give up
dodie("chdir('$dir')");

# timing file
open(A,">$name.log.new")||die("Can't open $name.log.new, $!");
print A "Starting dump: ",time(),"\n";

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

close(A);

# log file move
($out,$err,$res) = cache_command2("mv $name.log $name.log.old; bzip2 -f $name.log.old & mv $name.log.new $name.log");


