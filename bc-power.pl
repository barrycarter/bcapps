#!/bin/perl

# non python solution to https://codereview.stackexchange.com/questions/176840/compute-power-set-of-a-given-set-in-python?noredirect=1#comment335649_176840

# TODO: using this lib for debugging, final ans shouldn't require it

# TODO: not efficient, not golf, not original, not python

require "/usr/local/lib/bclib.pl";

for $i (0..2**($#ARGV+1)-1) {

  # list to hold this subset
  my(@list);

  # where in this subset we are
  $n = 0;

  debug(sprintf("%b", $i));

  # TODO: how big can $i be above?

  # binary representation of $i as a list (low bit first)
  for $j (split(//,sprintf("%b", $i))) {
    if ($j) {push(@list,$ARGV[$n])}
    $n++;
 #   debug("$i, $j");
  }

  debug("$i: LIST IS:", join(", ",@list));
#  debug("LIST IS",@list);

#  my(@list);

#  $j = $i;

#  while ($j=$j>>1) {
#    debug("I: $i, J: $j");
#  }
    
#  debug("I: $i");
#  $i = 0;


}



=item answer


See also https://codegolf.stackexchange.com/questions/9045/shortest-power-set-implementation


=cut
