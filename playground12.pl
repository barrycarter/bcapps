#!/bin/perl

# alternative sorts for bc-sgrep.pl (testing)

#

require "/usr/local/lib/bclib.pl";

# sortcmp("b","a");
# sortcmp("a","b");
# sortcmp("c","c");

debug(sortcmp("5","0006"));
debug(sortcmp("5","0006","-n"));
debug(sortcmp("5","0006","-R"));

=item sortcmp($left,$right,$opts)

Compare $left and $right using "sort -$opts", returning:

-1 if $left < $right
+1 if $left > $right
0 if $left == $right

TODO: do comparisons in both directions to avoid sort weirdnesses

TODO: LC_ALL=C or something similar; perhaps -s?

=cut

sub sortcmp {
  my($left,$right,$opts) = @_;
  local(*A);

  # shortcut if strings are byte-by-byte identical
  if ($left eq $right) {return 0;}

  # sort can behave oddly, both tests are required

  # left then right
  open(A, "|sort -c $opts 1> /tmp/out1.txt 2> /tmp/out2.txt");
  print A "$left\n$right\n";
  close(A);
  my($l) = $?;

  # right then left
  open(A, "|sort -c $opts 1> /tmp/out1.txt 2> /tmp/out2.txt");
  print A "$right\n$left\n";
  close(A);
  my($r) = $?;

  if ($l && !$r) {return 1;}
  if ($r && !$l) {return -1;}
  return 0;
}
