#!/bin/perl

# Given the output of 'join -a 1 -t '\0' afad.txt
# previouslydone.txt.srt', do... something

require "/usr/local/lib/bclib.pl";

while (<>) {
  my(@arr) = split(/\0/, $_);
  debug("<array len=$#arr+1>",@arr,"</array>");

  if ($#arr != 4) {
    debug("<array len=$#arr+1>",@arr,"</array>");
  }

}

