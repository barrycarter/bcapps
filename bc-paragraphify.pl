#!/bin/perl

# in the STDIN, convert single new lines to space, double new lines to
# true newline, so that paragraphs are "wiki style"

# TODO: maybe convert '= ' to nothing if requested

while (<>) {
  chomp();
  if (/^$/) {print "\n\n"; next;}
  print "$_ ";
}
