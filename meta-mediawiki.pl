#!/bin/perl

# Given a page formatted as sample-data/metamedia.txt, create multiple
# semantic Mediawiki pages reflecting the relations.

require "bclib.pl";

$all = read_file("sample-data/metamedia.txt");

# while ($all=~s/\[\[([^\[\]]*?\!\![^\[\]]*?)\]\]/parse_text($1)/iseg) {}

# keep tweaking $all until nothing left to do
for (;;) {
  $oldall = $all;
  $all=~s/\[\[([^\[\]]*?)\]\]/parse_text($1)/iseg;
  if ($oldall eq $all) {last;}
}

debug($all);

sub parse_text {
  my($text) = @_;

  debug("TEXT: $text");

  # if no special code, return as is
  unless ($text=~/\!\!/) {return "[[$text]]";}

  $text=~s/\!//isg;
  return "[[$text]]";
}

