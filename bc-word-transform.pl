#!/bin/perl

# This program uses the scrabble dictionary at scrab.db.94y.info

# NOTE: older versions of this program used /usr/dict/words and ispell

# Changes 'source' to 'target' using any/all of the following transforms:

require "/usr/local/lib/bclib.pl";

word_drop_letter("source");

# drop letter - drops letter from word

=item word_drop_letter($word)

Returns valid words/definitions formed by dropping letter for $word

=cut

sub word_drop_letter {
  my($word) = @_;
  my(@words);

  # potential words, quoted
  for $i (1..length($word)) {
    push(@words, "'".substr($word,0,$i-1).substr($word,$i)."'");
  }

  # build SQL query
  my($words) = join(",",@words);
  my($query) = "SELECT word,definition FROM words WHERE word IN ($words);";

}
