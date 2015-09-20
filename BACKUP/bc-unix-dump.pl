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

my($out,$err,$res) = cache_command2("find . -xdev -noleaf -warn -printf \"%T@ %s %i %m %y %g %u %D %p\n\" >> $name-files.txt.new");

print A "Dump ends: ",time(),"\n";




