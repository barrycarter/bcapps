#!/bin/perl

# converts text files like "chickenproblem.txt" into graphviz DOT files
# note chickenproblem.txt and EL/pv-magic.txt are in different formats

require "bclib.pl";

($data, $file) = cmdfile();
debug("DATA: $data");

# go through file, line by line
for $i (split(/\n/, $data)) {
  debug("I: $i");
  # ignore comments and blanks
  if ($i=~/^\#/ || $i=~/^\s*$/) {next;}

  # split by commas (neds = nodes/edges)
  @neds = split(/\,/, $i);

  # even numbered neds are nodes, odd are edges; go through nodes +
  # associate edges
  for ($j=0; $j<=$#neds; $j+=2) {
    # this node
    push(@gviz, $neds[j]);
  }
}

debug(@gviz);


