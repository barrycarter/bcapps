#!/bin/perl

# converts text files like "chickenproblem.txt" into graphviz DOT files
# note chickenproblem.txt and EL/pv-magic.txt are in different formats

require "bclib.pl";

($data, $file) = cmdfile();

# go through file, line by line
for $i (split(/\n/, $data)) {
  # ignore comments and blanks
  if ($i=~/^\#/ || $i=~/^\s*$/) {next;}

  # split by commas (neds = nodes/edges)
  @neds = split(/\,/, $i);

  # even numbered neds are nodes, odd are edges; go through nodes +
  # associate edges; no need to last entry, already handled by penultimate
  for ($j=0; $j<=$#neds-1; $j+=2) {
    # this is a node, and so is target
    $nodes{"$neds[$j];"} = 1;
    $nodes{"$neds[$j+2];"} = 1;
    # edge between them
    $edges{qq%$neds[$j] -> $neds[$j+2] [label="$neds[$j+1]"];%} = 1;
  }
}

debug("digraph x {");
debug(sort keys %nodes);
debug(sort keys %edges);
debug("}");


