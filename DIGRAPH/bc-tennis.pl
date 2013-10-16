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

  # 30 points or less just increases score, and duece with advantage wins
  if ($l[$n]<=2 || $l[$n]==5) {
    $l[$n]++;
    return @l[0..1];
  }

  # if you have disadvantage and score, go to deuce
  if ($l[$n] == 3) {return (4,4);}

  return "NIL";
}

@scores = (0,0);


debug(nextscore(@scores,0));
debug(nextscore(@scores,1));

die "TESTING";

while (@scores) {
  push(@scores, nextscore(@scores,0));
  push(@scores, nextscore(@scores,1));
  debug("SCORES",@scores);
}

