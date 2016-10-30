#!/bin/perl

# TODO: compress chains into single nodes (eg, if the only choice from
# page 1 is page 2 then page 3 then page 4, create a single 1,2,3,4
# node, not 4 nodes; Daredevil Park is notoriously linear)

require "/usr/local/lib/bclib.pl";

while (<>) {

  # ignore comments and blank lines + nuke \n
  if (/^\#/||/^\s*$/) {next;}
  chomp;

  # is this a color-coding line?
  if (/:/) {
    ($tag,$color,$name)=split(/:/,$_);
    $color{$tag}=$color;
    $name{$tag}=$name;
    next;
  }

  # regular line: split into source/target pages, further split target pages
  ($sour,$targ)=split(m!/!,$_);
  @targ=split(/\+/,$targ);

  # look for color-coding in source
  if ($sour=~s/([a-z\*\-]+)//isg) {$pagecolor{$sour}=$color{$1};}

  # flag source as page
  $ispage{$sour} = 1;

  for $i (@targ) {
    # all targets are pages
    $ispage{$i} = 1;

    # edge from source to target
    $isedge{$sour}{$i} = 1;
  }
}

# TODO: better filename
open(A,">/tmp/cyoa.dot");


# TODO: use subgraphs?
print A "digraph foo {\n";

# nodes for pages
for $i (sort keys %ispage) {
  # node names can't start with numbers, so add "_"
  print A qq!_$i [label="$i", fillcolor="$pagecolor{$i}", style="filled"];\n!;
}

# print the edges
for $i (sort keys %isedge) {
  for $j (sort keys %{$isedge{$i}}) {
    print A qq!_$i -> _$j;\n!;
  }
}

print A "}\n";

# TODO: print key on graph TODO: maybe print out actual graph using
# dot, neato, fdp, circo, twopi (twopi may be best because of the
# "outbound" nature of the game; neato works surprisingly well given
# that it's designed for undirected graphs)

# TODO: avoid edge crossing w/ options to programs above





