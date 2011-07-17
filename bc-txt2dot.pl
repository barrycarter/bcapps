#!/bin/perl

# Converts a text file to a graphviz-style DOT file (one-off use for now)

require "bclib.pl";

$txt = read_file("EL/tg-magic.txt");

for $i (split(/\n/,$txt)) {
  # ignore comments
  if ($i=~/^\#/) {next;}

  # main room
  $i=~s/^(.*?)://;

  # connecting rooms
  @rooms = split(/\,\s*/,$i);

  debug("I: $i, ROOMS:", @rooms);
}
