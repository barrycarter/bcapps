#!/bin/perl

# This program uses the scrabble dictionary at scrab.db.94y.info

# NOTE: older versions of this program used /usr/dict/words and ispell

# Changes 'source' to 'target' using any/all of the following transforms:

require "/usr/local/lib/bclib.pl";

# TODO: hardcoding source/target during testing only
($source, $target) = ("BARRY", "CARTER");

# load entire db into memory (faster?)
@res = sqlite3hashlist("SELECT * FROM words", "/home/barrycarter/BCINFO/sites/DB/scrab.db");

for $i (@res) {
  # map word to definition
  $worddef{$i->{word}} = $i->{definition};
  # anagrams
  push(@{$ana{$i->{sig1}}}, $i->{word});
  # currently unused
  push(@{$lba{$i->{sig2}}}, $i->{word});
}

warn "FORCE DEBUGGING";
$globopts{debug}=1;

@source = ($source);
@target = ($target);

for (;;) {
  # first, go forward from source word
  %swords = word_transforms(@source);

  for $i (keys %swords) {
    # TODO: this seems kludgey somehow
    # figure out original word
    $oword = $swords{$i};
    $oword=~s/:.*$//isg;

    # note that source has hit this words + path
    $source{$i} = "$source{$oword} $swords{$i}";
    debug("SWORDS: $i -> $swords{$i}, SOURCE: $i -> $source{$i}");

    # do any match things target has hit?
    if ($target{$i}) {
      $final = $i; $alldone = 1; last;
    }
  }

  # if not, go backwards from target word
  %twords = word_transforms(@target);

  for $i (keys %twords) {
    # TODO: this seems kludgey AND redundant
    $oword = $swords{$i};
    $oword=~s/:.*$//isg;

    # note that target has hit this word + path
    $target{$i} = "$target{$oword} $twords{$i}";

    # do any match things target has hit?
    if ($source{$i}) {
      $final = $i; $alldone = 1; last;
    }
  }

  # TODO: kludgey because Im nested fairly deep
  if ($alldone) {last;}

  # new source and target for next round
  @source = keys %swords;
  @target = keys %twords;

  if (++$count>=6) {die "TESTING";}
}

debug("FINAL: $final","SOURCE: $source{$final}", "TARGET: $target{$final}");


=item word_transforms(@words)

Given a list of words, return all one-level transforms of those words
in a hash mapping new word to "old_word:transform_type"

=cut

sub word_transforms {
  my(@words) = @_;
  my(%words);
  my(%ret);

  for $word (@words) {

    # "superhash" of words and definitions
    %{$words{drop}} = word_drop_letter($word);
    %{$words{add}} = word_add_letter($word);
    %{$words{change}} = word_change_letter($word);
    %{$words{anagram}} = word_anagram($word);

    # for each type of transform
    for $i (keys %words) {
      # for each word in type $i transform
      for $j (keys %{$words{$i}}) {
	# if this word already defined, weve already got path too
	#      if ($definition{$j}) {next;}
	#      $definition{$j} = $words{$i}->{$j};
	$ret{$j} = "$word:$i";
#      $path{$j} = "$path{$word} $word:$i:$j";
#      push(@words, $j);
    }
  }
}

  return %ret;
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
      push(@words, uc(substr($word,0,$i).$j.substr($word,$i)));
    }
  }

#  debug("SIZE: $#words");
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
      push(@words, uc(substr($word,0,$i-1).$j.substr($word,$i)));
    }
  }

#  debug("SIZE: $#words");
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

  # look through anagram list for this sig
  for $i (@{$ana{$sig1}}) {
    if ($i eq $word) {next;}
    $rethash{$i} = $worddef{$i};
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
    if ($worddef{$i}) {
      $rethash{$i} = $worddef{$i};
    }
  }

  return %rethash;
}
