#!/bin/perl

# Given a file x of regular expressions and a list of files to test,
# shows which expressions in x match which lines in the tested files

# this is EXTREMELY inefficient; the only slight efficiency is that
# Unix caches file accesses, so running these one after the other
# isn't as slow as running them at different times

# http://stackoverflow.com/questions/1331457/how-to-determine-which-pattern-in-a-file-matched-with-grep

# http://stackoverflow.com/questions/29373248/egrep-f-regexlist-inputfile-show-unused-patterns-in-regexlist

require "/usr/local/lib/bclib.pl";

# determine regexes (will exclude comments and empty lines in next step
my(@regs) = split(/\n/,read_file(shift()));

# this assumes files have no spaces
my($files) = join(" ",@ARGV);


for $i (@regs) {
  if ($i=~/^\s*$/ || $i=~/^\#/) {next;}
  chomp($i);

  # write to file, but dont overwrite
  $count++;
  if (-f "regexp-$count.txt" || -f "output-$count.txt") {
    die "regexp-$count.txt and/or output-$count.txt already exists!";}
  # in theory, could do "egrep '$i' files" but this is more reliable?
  write_file("$i\n","regexp-$count.txt");

  # write the regex to the output file as well (convenience)
  write_file("REGEX: $i\n", "output-$count.txt");

  # doesnt actually do anything, just prints out command
  # can theoretically run this in parallel (but might be CPU/disk intensive?)
  print "egrep -af regexp-$count.txt $files >> output-$count.txt\n";

}


