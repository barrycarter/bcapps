#!/bin/perl

# Recursively enumerates all paths in "chicken-fox-wheat" problem
# STATE = "xyz|u" meaning x,y,z on start site, u on terminal side
# M = man = can transport self w/ 0-1 others

require "bclib.pl";

# breadth first path finding (recursive would be more fun, but less efficient)

# start with the 0-step path of starting state
push(@path, sort_state("MFCW|"));

# a "path" is a bunch of strings with -> between them

# TODO: stop on cycles
for (;;) {

  # find first path
  $elt = shift(@path);

  # if nothing left, we're done
  unless ($elt) {last;}

  # is it cyclic? if so, treat is as a final result
#  debug("CYCLIC?",cyclic_pathq($elt));
  if (cyclic_pathq($elt)) {
    push(@res, $elt);
    next;
  }

  # find last state in first path
  $elt=~/(.{5})$/;
  $lstate = $1;

  # if the last state is fatal, no point in going further
  # same if last state is goal ("|" on far left means all on right side)
  if (fatal_stateq($lstate) || $lstate=~/^\|/) {
    debug("PATH: $elt, FATAL: $lstate");
    push(@res, $elt);
    next;
  }

  # find all reachable states
  @reach = find_states($lstate);

  # and push onto path
  for $i (@reach) {
    push(@path, "$elt -> $i");
  }

#  debug(@path);

}

debug("FINAL",@res);

=item find_states($start);

Given a starting state, find all possible paths, but end if there's a cycle

=cut

sub find_states {
  my($state) = @_;
  my(@res);

  # which side is man on?
  my($left,$right) = split(/\|/, $state);
  
  # left side?
  if ($left=~/m/i) {
    # find other creatures on left side
    for $j (split(//,$left)) {
      # special case to transfer man himself
      if ($j=~/^m$/i) {push(@res,transport($state,"")); next;}
      push(@res,transport($state,$j));
    }
  } elsif ($right=~/m/i) {
    # find other creatures on right side
    for $j (split(//,$right)) {
      # special case to transfer man himself
      if ($j=~/^m$/i) {push(@res,transport($state,"")); next;}
      push(@res,transport($state,$j));
    }
  } else {
    die "WTF";
  }
  
  return @res;
}

=item transport($state,$cr)

Given a $state and a $cr{eature}, move the creature to the other side
(along w/ man); if $cr is empty, just move man. If man and $cr are on
different sides, return $state

=cut

sub transport {
  my($state,$cr) = @_;

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
    return sort_state("$left|$right");
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
    return sort_state("$left|$right");
  }

  # can't do anything, so return original state
  return $state;

}

=item sort_state($state)

Given a state, sort left and right sides to canonize

=cut

sub sort_state {
  my($state) = @_;

  # split into left and right
  my($left,$right) = split(/\|/, $state);

  # sort letters
  $left = join("",sort(split(//,$left)));
  $right = join("",sort(split(//,$right)));

  return "$left|$right";
}

=item cyclic_pathq($path)

Given a path, determine if its cyclic

=cut

sub cyclic_pathq {
  my($path) = @_;
  my(%seen);

  # split path into states
  my(@states) = split(/\s*->\s*/,$path);

  # check for dupes
  for $i (@states) {
    # state seen, path is cyclic
    if ($seen{$i}) {return 1;}
    # mark state as now seen
    $seen{$i}=1;
  }

  # no dupes? not cyclic!
  return 0;
}

=item fatal_stateq($state)

Is $state fatal (chicken eats wheat or fox eats chicken)?

=cut

sub fatal_stateq {
  my($state) = @_;
  my($left,$right) = split(/\|/, $state);
  my(%side);

  # the side the man is on can never be fatal
  if ($left=~/m/i) {
    for $i (split(//,$right)) {
      $side{$i} = "right";
    }
  } elsif ($right=~/m/i) {
    for $i (split(//,$left)) {
      $side{$i} = "left";
    }
    } else {
      die "WTF";
    }

#  debug("SIDE",%side);

  # if the man and the chicken are on the same side, state is never
  # fatal ($side{C}="", since it's not set above
  unless ($side{C}) {return 0;}
  
  # same side?
  if ($side{F} eq $side{C}) {return 1;}
  if ($side{C} eq $side{W}) {return 1;}
  return 0;
}


 
