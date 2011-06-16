#!/bin/perl

# Attempts to create better maps for EL using el-wiki.net information

# Desert Pines = first example

require "bclib.pl";

($all) = cmdfile();

for $i (split("\n",$all)) {
  # are we in a new section?
  if (/== (.*?) ==/) {$section = $1; next;}

  # does this line have coordinates (maybe more than one)
  @coords = ();
  while ($i=~s/\[(\d+\,\d+)\]//) {
    push(@coords, $1);
  }

  unless (@coords) {
    debug("No coords, skipping");
    next;
  }

  # ignore [[File:thing]]
  $i=~s/\[\[file:.*?\]\]//isg;

  # look for the first [[thing]]; if none, use first word as name
  if ($i=~/\[\[(.*?)\]\]/) {
    $name = $1;
  } else {
    $name = $i;
    $name=~s/\s.*$//;
  }

  debug("$name, COORDS:",@coords);
}

