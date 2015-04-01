#!/bin/perl

# alternative sorts for bc-sgrep.pl (testing)

# TODO: LC_ALL=C or something similar; perhaps -s?

require "/usr/local/lib/bclib.pl";

sortcmp("b","a");
# sortcmp("a","b");

=item sortcmp($left,$right,$opts)

Compare $left and $right using "sort -$opts", returning:

-1 if $left < $right
+1 if $left > $right
0 if $left == $right

TODO: do comparisons in both directions to avoid sort weirdnesses

=cut

sub sortcmp {
  my($left,$right,$opts) = @_;
  local(*A);
#  open(A, "|sort -c $opts 1> /tmp/out1.txt 2> /tmp/out2.txt");
  open(A, "|sort -c 1> /tmp/out1.txt 2> /tmp/out2.txt");
#  print A "$left\n$right\n";
  print A "b\na\n";
  my($cval) = close(A);
  debug("SUCC: $cval / $? / $!");
}
