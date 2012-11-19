#!/bin/perl

# This program uses the scrabble dictionary at scrab.db.94y.info

# NOTE: older versions of this program used /usr/dict/words and ispell

# Changes 'source' to 'target' using any/all of the following transforms:

require "/usr/local/lib/bclib.pl";

# debug(word_drop_letter("sources"));
# debug(word_add_letter("source"));
# debug(word_change_letter("source"));
# debug(word_anagram("source"));

# load entire db into memory (faster?)
@res = sqlite3hashlist("SELECT word,definition FROM words", "/home/barrycarter/BCINFO/sites/DB/scrab.db");

for $i (@res) {$worddef{$i->{word}} = $i->{definition};}

debug("WORDDEF:",%worddef);

warn "NO ANAGRAMS WHILE TESTING";

@words = ("A");

while (@words) {

  $word = shift(@words);

  # if weve already seen this word, ignore it
  if ($seen{$word}) {next;}
  $seen{$word} = 1;

  print "$word: $path{$word}\n";

  # "superhash" of words and definitions
  %{$words{drop}} = word_drop_letter($word);
  %{$words{add}} = word_add_letter($word);
  %{$words{change}} = word_change_letter($word);
  # TODO: re-add anagrams!
#  %{$words{anagram}} = word_anagram($word);

  # for each of the new words, record definition and path to word
  for $i (keys %words) {
    for $j (keys %{$words{$i}}) {
      # if this word already defined, weve already got path too
      if ($definition{$j}) {next;}
      $definition{$j} = $words{$i}->{$j};
      $path{$j} = "$path{$word} $word:$i:$j";
      push(@words, $j);
    }
  }
}

=item word_drop_letter($word)

Returns valid words/definitions formed by dropping letter from $word

=cut

sub word_drop_letter {
  my($word) = @_;
  my(@words);
  my(%rethash);

  # potential words, quoted
  for $i (1..length($word)) {
#    push(@words, "'".uc(substr($word,0,$i-1).substr($word,$i))."'");
    push(@words, uc(substr($word,0,$i-1).substr($word,$i)));
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
#      push(@words, "'".uc(substr($word,0,$i).$j.substr($word,$i))."'");
      push(@words, uc(substr($word,0,$i).$j.substr($word,$i)));
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
    for $j ("A".."Z") {
      # cant change letter for itself, pointless
      if (substr($word,$i-1,1) eq $j) {next;}
#      push(@words, "'".uc(substr($word,0,$i-1).$j.substr($word,$i))."'");
      push(@words, uc(substr($word,0,$i-1).$j.substr($word,$i)));
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

  # look in worddef hash (global)
  for $i (@list) {
    debug("CHECKING: $i");
    if ($worddef{$i}) {
      debug("FOUND: $i");
      $rethash{$i} = $worddef{$i};
    }
  }

  return %rethash;

  # build SQL query
  my($words) = join(",",@list);
  my(@res) = sqlite3hashlist("SELECT word,definition FROM words WHERE word IN ($words)", "/home/barrycarter/BCINFO/sites/DB/scrab.db");

  # return just word and definition
  for $i (@res) {
    $rethash{$i->{word}} = $i->{definition};
  }

  return %rethash;
}


