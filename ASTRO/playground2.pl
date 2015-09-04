#!/bin/perl

require "/usr/local/lib/bclib.pl";

# Clenshaw method for ChebyshevT

debug(chebyshevt([1,5,2],0.01));

=item chebyshevt([list],x)

Compute the ChebyshevT polynomial for list at x, where the nth coefficient
is given by the nth element of list

=cut

sub chebyshevt {
  my($lref,$x) = @_;
  my(@a) = @$lref;
  my($len) = $#a;
  my(@b);

  # compute the b(x)'s
  for $i (0..$len-1) {
    $b[$len-$i] = $a[$len-$i]+2*$x*$b[$len-$i+1]-$b[$len-$i+2];
  }

  return $a[0]+$x*$b[1]-$b[2];
}
