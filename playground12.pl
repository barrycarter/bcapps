#!/bin/perl

# alternative sorts for bc-sgrep.pl (testing)

# TODO: LC_ALL=C or something similar; perhaps -s?

require "/usr/local/lib/bclib.pl";

# sortcmp("b","a");
sortcmp("a","b");

=item sortcmp($left,$right,$opts)

Compare $left and $right using "sort -$opts", returning:

-1 if $left < $right
+1 if $left > $right
0 if $left == $right

TODO: do comparisons in both directions to avoid sort weirdnesses

=cut

sub sortcmp {
  my($left,$right,$opts);
  local(*A);
  debug(open(A, "|sort -c $opts"));
  print A "$left\n$right\n";
  debug(close(A));
  debug("SUCC: $?, $!");
}
