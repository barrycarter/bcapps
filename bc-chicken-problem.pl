#!/bin/perl

# Recursively enumerates all paths in "chicken-fox-wheat" problem
# STATE = "xyz|u" meaning x,y,z on start site, u on terminal side
# M = man = can transport self w/ 0-1 others

require "bclib.pl";

$t[0] = transport("MFCW|", "C");
$t[1] = transport($t[0], "");

debug(@t);

=item find_states($start);

Given a starting state, find all possible paths, but end if there's a cycle

=cut

sub find_states {
  my($state) = @_;

  # which side is man on?
  my($left,$right) = split(/\|/, $state);
  
  # left side?
  if ($left=~/m/i) {
    # find other creatures on left side
    for $j (split(//,$left)) {
      if ($j eq "m") {next;}
      # remove creature and man from left side
      my($newleft)= $left;
      $newleft =~s/$j//i;
      # a
    }
  }
}


=item transport($state,$cr)

Given a $state and a $cr{eature}, move the creature to the other side
(along w/ man); if $cr is empty, just move man. If man and $cr are on
different sides, return $state

=cut

sub transport {
  my($state,$cr) = @_;
  debug("GOT: $state");

  # split sides
  my($left,$right) = split(/\|/, $state);

  # man on left
  if ($left=~/m/i) {
    # create on right? fail!
    if ($right=~/$cr/i) {return $state;}
    
    # otherwise, remove man/$cr from left side + add to right
    # [m$cr] and [m|$cr] below both fail
    $left=~s/$cr//i;
    $left=~s/m//i;
    $right.= "M$cr";
    debug("RETURNING $left$right");
    return "$left|$right";
  }

  # man on right
  if ($right=~/m/i) {
    # create on left? fail!
    if ($left=~/$cr/i) {return $state;}
    
    # otherwise, remove man/$cr from right side + add to left
    # [m$cr] and [m|$cr] below both fail
    $right=~s/$cr//i;
    $right=~s/m//i;
    $left .= "M$cr";
    debug("RETURNING $left$right");
    return "$left|$right";
  }

  # can't do anything, so return original state
  return $state;

}



  



