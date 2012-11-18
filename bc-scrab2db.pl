#!/bin/perl

# Converts scrabble-words.txt (see oneliners.sh to see how I got
# scrabble-words.txt from scrabble-words.html)

require "/usr/local/lib/bclib.pl";

for $i (split(/\n/, read_file("/home/barrycarter/BCGIT/scrabble-words.txt"))) {
  # split word and definition (words always in caps!)
  $i=~/^([A-Z]+)\s+(.*?)$/;
  ($word, $def) = ($1, $2);

  # list of words for this definition
  @words = ($word);

  # sometimes definition itself contains other words (as "-- FOO/BAR")
  if ($def=~s/\-\-\s+([A-Z\/]+)//) {
    push(@words, split(/\//, $1));
  }

  # I find "-- foo" annoying
  $def=~s/\-\-(.*?)$/($1)/;

  # sqlite3 escape
  $def=~s/\'/''/isg;

  # for each word, we include two "signatures"
  # sig1: letters in word in alphabetical order
  # sig2: sig1 with duplicates removed

  for $j (@words) {
    $sig1 = join("",sort(split(//,$j)));
    $sig2 = $sig1;
    $sig2=~s/(.)\1+/$1/sg;
    push(@querys, "INSERT INTO words (word, definition, sig1, sig2) VALUES
('$j', '$def', '$sig1', '$sig2');");
  }
}

print << "MARK";
DROP TABLE IF EXISTS words;
CREATE TABLE words (word, definition, sig1, sig2);
BEGIN;
MARK
;

print join("\n",@querys),"\n";

print "COMMIT;\n";



