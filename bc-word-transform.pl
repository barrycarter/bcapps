#!/bin/perl

# This program uses the scrabble dictionary at scrab.db.94y.info

# NOTE: older versions of this program used /usr/dict/words and ispell

# Changes 'source' to 'target' using any/all of the following transforms:

require "/usr/local/lib/bclib.pl";

# debug(word_drop_letter("adulate"));
debug(word_add_letter("source"));

=item word_drop_letter($word)

Returns valid words/definitions formed by dropping letter for $word

=cut

sub word_drop_letter {
  my($word) = @_;
  my(@words);
  my(%rethash);

  # potential words, quoted
  for $i (1..length($word)) {
    push(@words, "'".uc(substr($word,0,$i-1).substr($word,$i))."'");
  }

  # build SQL query
  my($words) = join(",",@words);
  my(@res) = sqlite3hashlist("SELECT word,definition FROM words WHERE word IN ($words)", "/home/barrycarter/BCINFO/sites/DB/scrab.db");

  # return just word and definition
  # TODO: I really need to write an sqlite3hash function
  for $i (@res) {
    $rethash{$i->{word}} = $i->{definition};
  }

  return %rethash;
}

=item word_add_letter($word)

Returns valid words/definitions formed by dropping letter to $word

=cut

sub word_add_letter {
  my($word) = @_;
  my(@words);
  my(%rethash);

  # potential words, quoted
  for $i (1..length($word)) {
    for $j ("a".."z") {
      push(@words, "'".uc(substr($word,0,$i).$j.substr($word,$i))."'");
    }
  }

  # build SQL query
  my($words) = join(",",@words);
  my(@res) = sqlite3hashlist("SELECT word,definition FROM words WHERE word IN ($words)", "/home/barrycarter/BCINFO/sites/DB/scrab.db");

  # return just word and definition
  # TODO: I really need to write an sqlite3hash function
  for $i (@res) {
    $rethash{$i->{word}} = $i->{definition};
  }

  return %rethash;
}


