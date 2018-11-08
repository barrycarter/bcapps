#!/bin/perl

# Given a list of words on the stdin, bin them so that the Levenshtein
# distance between any two in the bin is the length of the words in
# the bin (ie, maximal)

require "/usr/local/lib/bclib.pl";

my(@words);

while (<>) {chomp; push(@words, $_);}

# find number of compatible words for each word

# TODO: this could be done twice as fast

# iscombat = pair list
my(%iscompat);

for $i (@words) {
  for $j (@words) {
    if (compatible($i,$j)) {$iscompat{$i}{$j}=1;}
  }
}

# debug(scalar(keys $iscompat{"cheap"}));

my(@order) = sort {scalar(keys $iscompat{$b}) <=> scalar(keys $iscompat{$a})} keys %iscompat;

for $i (@order) {debug("$i");}




# hash of words we've already seen
my(%skip);



# determines if a given word is compatible with a given list of words
# (uses %iscompat hash)

sub word_ok_in_list {
  my($word, $listref) = @_;
  my(@list) = @$listref;
  my($i);

  for $i (@list) {unless ($iscompat{$word}{$i}) {return 0;}}
  return 1;
}



# program specific subroutine (assumed same length, limited case)

sub compatible {
  my($w1, $w2) = @_;

  # this is maybe too clever
  my(@w1) = map(ord, split(//, $w1));
  my(@w2) = map(ord, split(//, $w2));

  for (my($i) = 0; $i < $#w1; $i++) {
    if ($w1[$i] == $w2[$i]) {return 0;}
  }

  return 1;
}

