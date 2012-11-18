#!/bin/perl

# This program uses the scrabble dictionary at scrab.db.94y.info

# NOTE: older versions of this program used /usr/dict/words and ispell

# Changes 'source' to 'target' using any/all of the following transforms:

require "/usr/local/lib/bclib.pl";

# debug(word_drop_letter("sources"));
# debug(word_add_letter("source"));
# debug(word_change_letter("source"));
debug(word_anagram("source"));

=item word_drop_letter($word)

Returns valid words/definitions formed by dropping letter from $word

=cut

sub word_drop_letter {
  my($word) = @_;
  my(@words);
  my(%rethash);

  # potential words, quoted
  for $i (1..length($word)) {
    push(@words, "'".uc(substr($word,0,$i-1).substr($word,$i))."'");
  }

  return word_get(@words);
}

=item word_add_letter($word)

Returns valid words/definitions formed by dropping letter to $word

=cut

sub word_add_letter {
  my($word) = @_;
  my(@words);

  # potential words, quoted
  for $i (0..length($word)) {
    for $j ("a".."z") {
      push(@words, "'".uc(substr($word,0,$i).$j.substr($word,$i))."'");
    }
  }

  debug("SIZE: $#words");
  return word_get(@words);
}

=item word_change_letter($word)

Returns valid words/definitions formed by changing single letter of $word

=cut

sub word_change_letter {
  my($word) = @_;
  my(@words);

  # potential words, quoted
  for $i (1..length($word)) {
    for $j ("a".."z") {
      # cant change letter for itself, pointless
      if (substr($word,$i-1,1) eq $j) {next;}
      push(@words, "'".uc(substr($word,0,$i-1).$j.substr($word,$i))."'");
    }
  }

  debug("SIZE: $#words");
  return word_get(@words);
}

=item word_anagram($word)

Return anagrams of $word, with definitions

=cut

sub word_anagram {
  # <h>Oh, my word!</h>
  my($word) = @_;
  $word = uc($word);
  my(%rethash);

  # determine sig1 of word (as caps)
  my($sig1) = uc(join("",sort(split(//,$word))));

  # query (explicitly exclude word itself)
  my(@res) = sqlite3hashlist("SELECT word,definition FROM words WHERE sig1='$sig1' AND word != '$word'", "/home/barrycarter/BCINFO/sites/DB/scrab.db");

  # return just word and definition
  for $i (@res) {
    $rethash{$i->{word}} = $i->{definition};
  }

  return %rethash;
}

=item word_get(@list)

Given @list, a list of potential words (quoted), return those that are actually
words and their definitions.

=cut

sub word_get {
  my(@list) = @_;
  my(%rethash);

  # build SQL query
  my($words) = join(",",@list);
  my(@res) = sqlite3hashlist("SELECT word,definition FROM words WHERE word IN ($words)", "/home/barrycarter/BCINFO/sites/DB/scrab.db");

  # return just word and definition
  for $i (@res) {
    $rethash{$i->{word}} = $i->{definition};
  }

  return %rethash;
}


