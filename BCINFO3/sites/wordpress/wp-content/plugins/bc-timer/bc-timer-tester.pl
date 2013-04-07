#!/bin/perl

# Generates "all possible" formats for a given time spec to test bc-timer plugin

require "/usr/local/lib/bclib.pl";

# need these in order (sort of) [not bothering w centuries]
@times=split(//,"YmUdHMS");

# names of the time units
@names=("years", "months", "weeks", "days", "hours", "minutes", "seconds");

# map times to names
for $i (0..$#times) {
  $names{$times[$i]} = $names[$i];
}

@power = power_set([@times]);

for $i (@power) {
  # add % signs
  map($_="%$_ $names{$_}", @{$i});
  $str = join(", ", @{$i});
  print qq%[bctimer time="315532800" format="$str"]<br>\n%;
}

=item power_set([@s])

Returns all subsets of @s (could I just use Data::PowerSet or something?)

=cut

sub power_set {
  my($sr) = @_;
  my(@s) = @{$sr};
  my(@res);

  # clever way to find all subsets w/o multiple for loops
  for $i (0..2**($#s+1)) {
    # TODO: more efficient way to see which bits are 'lit'?
    my(@list) = ();
    for $j (0..$#times) {
      # intentional use of bitand below
      if ($i & 2**$j) {
	push(@list, $times[$j]);
    }
  }
  push(@res, [@list]);
  }

  return @res;
}
