#!/bin/perl

# convert non-grey pixels in an XPM file to white ("decolorize"
# Peanuts colored versions to compare to originals)

require "/usr/local/lib/bclib.pl";

$all = read_file("/tmp/2013-03-18.xpm");

$all=~s/(\".*?\sc\s.*?\")/white($1)/seg;

debug("ALL: $all");

sub white {
  my($str) = @_;

  # keep grays as is
  if ($str=~/gray/) {return $str;}
  if ($str=~/\#(..)\1\1/) {return $str;}

  # change to white
  $str=~s/\#.{6}/\#FFFFFF/;
  return $str;
}


