#!/bin/perl

# non python solution to https://codereview.stackexchange.com/questions/176840/compute-power-set-of-a-given-set-in-python?noredirect=1#comment335649_176840

# TODO: using this lib for debugging, final ans shouldn't require it

# TODO: not efficient, not golf, not original

require "/usr/local/lib/bclib.pl";

for $i (0..2**($#ARGV+1)-1) {

  # binary representation of $i
#  $j = unpack("B32", pack("N", $i));

  $j = sprintf("%b", $i);

  debug("I: $i, J: $j");

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
