#!/bin/perl

# checks that the given log directory (quora) has all of the necessary
# files and look for possible errors

require "/usr/local/lib/bclib.pl";

# TODO: $dir must be a number, but i dont make that clear here
my($dir) = shift;

dodie("chdir('/home/barrycarter/QUORA/LOG/$dir')");

# TODO: check to see if status.txt or possiblebad.txt already exists

open(A,">status.txt");

# TODO: there HAS to be a better way to write this error condition
for $i ("0000".."9999") {
  if (-f "$dir$i.html" || -f "$dir$i.html.bz2") {next;}
  print A "$dir$i.html or $dir$i.html.bz2 not found\n";
  close(A);
  exit;
}

print A "all 10K files found\n";
close(A);

# TODO: this assumes bzip'dness = bad
system("bzfgrep -L 'Revision #' *.html* > possiblebad.txt");


