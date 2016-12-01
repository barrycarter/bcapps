#!/bin/perl

# Perl script to run on "fresh" VMs to see what they can install

# this script creates a shell script, which is the one that actually
# gets scp's over (can't use rsync, not all machines support at
# startup

require "/usr/local/lib/bclib.pl";

open(A,">yumprovides.sh");
open(B,">dnfprovides.sh");

for $i (split(/\n/, read_file("pkglist.txt"))) {

  if ($i=~/^\#/ || $i=~/^\s*$/ ) {next;}

  print A "echo $i START; yum provides '*/$i'; echo $i END\n";
  print B "echo $i START; dnf provides '*/$i'; echo $i END\n";

}



close(A);
close(B);


# TODO: add aptitude once I figure out its "yum provides" equivalent

