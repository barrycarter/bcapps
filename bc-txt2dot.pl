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
    if ($j=~/^\d/) {$j="_$j";}
    push(@edges, "$node -> $j;");
  }
}

print "digraph tgmagic {\n";
print join("\n", @nodes)."\n";
print join("\n", @edges)."\n";
print "}\n";
