#!/bin/perl

# Given a list of words on the stdin, bin them so that the Levenshtein
# distance between any two in the bin is the length of the words in
# the bin (ie, maximal)

# ugly way to test (confirms 0th chars are diff)

# bc-partition-words.pl < batch1.txt | perl -nle '@l=split(//, $_);
# print $l[0]' | sort -u | wc

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

@testing = ("odium", "whack", "scuzz", "ortho", "lubra", "expel", "along", "marsh", "indie", "whelk", "rumor", "frump", "storm", "cheek", "cheap", "apsos", "gizmo", "toric", "halls", "stoic", "axman", "dingy", "afore", "argot", "recap", "lucre", "guppy", "death", "sonny", "poxed", "mauve", "holly", "focus", "eased", "nicad", "pieta", "merit", "irate", "earls", "timid", "dealt", "guyed", "musty", "semen", "galas", "doest", "diode", "drily", "greps", "geoid");

my(@test);

for $i (@testing) {@test = @{word_ok_in_list($i, \@test)};}

print join(", ", @test),"\n";


# debug(@testing);

die "TESTING";

# print join(", ", keys $iscompat{"odium"}),"\n";

# debug(scalar(keys $iscompat{"cheap"}));

my(@order) = sort {scalar(keys $iscompat{$b}) <=> scalar(keys $iscompat{$a})} keys %iscompat;

print join(", ", @order),"\n";

# for $i (@order) {debug("$i");}

my(@test);

for $i (@order) {@test = @{word_ok_in_list($i, \@test)};}

print join(", ", @test),"\n";


# hash of words we've already seen
my(%skip);



# determines if a given word is compatible with a given list of words
# (uses %iscompat hash); if so, return list w/ $word appended, else as is

sub word_ok_in_list {
  my($word, $listref) = @_;
  my(@list) = @$listref;
  my($i);

  for $i (@list) {unless ($iscompat{$word}{$i}) {return \@list}};
  push(@list, $word);
  return \@list;
}



# program specific subroutine (assumed same length, limited case)

sub compatible {
  my($w1, $w2) = @_;

  # this is maybe too clever
  my(@w1) = map(ord, split(//, $w1));
  my(@w2) = map(ord, split(//, $w2));

  for (my($i) = 0; $i <= $#w1; $i++) {
    if ($w1[$i] == $w2[$i]) {return 0;}
  }

  return 1;
}

