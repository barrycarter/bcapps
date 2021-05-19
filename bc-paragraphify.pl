#!/bin/perl

# in the STDIN, convert single new lines to space, double new lines to
# true newline, so that paragraphs are "wiki style"

while (<>) {
  chomp();
  if (/^$/) {print "\n\n"; next;}
  print "$_ ";
}
