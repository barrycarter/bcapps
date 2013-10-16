#!/bin/perl

# script to create state diagram for tennis game

require "/usr/local/lib/bclib.pl";

# scores:
# 0 = 0
# 1 = 15
# 2 = 30
# 3 = duece w disadvantage
# 4 = 40 (or deuce)
# 5 = deuce w advantage
# 6 = 60 (victory)

# if x has x points, y has y points, and n scores (n=0 -> x, n=1 ->y),
# return next score in x,y format

sub nextscore {
  my(@l) = @_;
  my($n) = $l[2];
  debug("nextscore(@l)");

  # 15 points or less just increases score, and duece with advantage wins
  if ($l[$n]<=2 || $l[$n]==5) {
    # jump from 30 to 40
    if ($l[$n]==2) {$l[$n]+=2;} else {$l[$n]++;}
    return @l[0..1];
  }

  # if you have disadvantage and score, go to deuce
  if ($l[$n] == 3) {return (4,4);}

  # you have 40, opponent has 30 or less -> you win
  if ($l[$n]==4 && $l[1-$n]<=2) {
    $l[$n] = 6;
    return @l[0..1];
  }

  # deuce
  if ($l[$n]==4 && $l[1-$n]==4) {
    $l[$n] = 5;
    $l[1-$n] = 3;
    return @l[0..1];
  }

  return "NIL";
}

# fill in the state diagram starting with score of $x,$y (recursion)

sub statescore {
  my($x,$y) = @_;
  debug("statescore($x,$y)");

  # if either side has won, nothing more to do
  if ($x==6 || $y==6) {return;}

  # fill in hash for 0 and 1 values and recurse unless I already have them
  unless ($statehash{$x}{$y}{0}) {
    $statehash{$x}{$y}{0} = nextscore($x,$y,0);
    statescore(nextscore($x,$y,0));
  }

  unless ($statehash{$x}{$y}{1}) {
    $statehash{$x}{$y}{1} = nextscore($x,$y,1);
    statescore(nextscore($x,$y,1));
  }
}


statescore(0,0);

die "TESTING";

@scores = (0,0);


debug(nextscore(@scores,0));
debug(nextscore(@scores,1));

die "TESTING";

while (@scores) {
  push(@scores, nextscore(@scores,0));
  push(@scores, nextscore(@scores,1));
  debug("SCORES",@scores);
}

