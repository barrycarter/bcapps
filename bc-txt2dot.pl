#!/bin/perl

# Converts a text file to a graphviz-style DOT file (one-off use for now)

require "bclib.pl";

$txt = read_file("EL/tg-magic.txt");

for $i (split(/\n/,$txt)) {
  # ignore comments
  if ($i=~/^\#/) {next;}

  # main room
  $i=~s/^(.*?)://;
  $node = $1;

  # graphviz dislikes nodes that start w/ numbers
  if ($node=~/^\d/) {$node="_$node";}

  # connecting rooms
  # <h>The var name gives away that I'm doing this for a specific reason!</h>
  @rooms = split(/\,\s*/,$i);

  # node
  push(@nodes, "$node;");

  # edges
  for $j (@rooms) {
    # as above
    if ($j=~/^\d/) {$j="_$j";}

    # TODO: cheating here, since I know TG Magic Garden graph is bidirectional
    if ($edge{$node}{$j} || $edge{$j}{$node}) {next;}

    # NOTE: putting semicolons at EOL actually breaks dot!
    push(@edges, "$node -- $j");
    $edge{$node}{$j} = 1;
  }
}

debug("ROOMS",@rooms,"EDGES",@edges);

open(A,">/home/barrycarter/BCGIT/EL/tg-magic.dot");
print A "graph tgmagic {\n";
print A join("\n", @nodes)."\n";
print A join("\n", @edges)."\n";
print A "}\n";
close(A);

# just for testing
system("neato -Nshape=circle -Nfontsize=9 -Gnslimit=9999 -Gmclimit=9999 -Tpng EL/tg-magic.dot | display -");
