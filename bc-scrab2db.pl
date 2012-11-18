#!/bin/perl

# Converts scrabble-words.txt (see oneliners.sh to see how I got
# scrabble-words.txt from scrabble-words.html)

require "/usr/local/lib/bclib.pl";

for $i (split(/\n/, read_file("scrabble-words.txt"))) {
  # split word and definition (words always in caps!)
  $i=~/^([A-Z]+)\s+(.*?)$/;
  ($word, $def) = ($1, $2);

  # sometimes definition itself contains other words (as "-- FOO/BAR")
  if ($def=~/\-\-\s+(.*?)$/) {
    debug("OTHER WORDS: $1");
  }

  debug("WORD/DEF: $word/$def");
}

