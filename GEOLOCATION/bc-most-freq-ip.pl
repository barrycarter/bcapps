#!/bin/perl

# given sortedips.txt, determine which netblocks appear most often;
# similar to bc-most-freq.pl, but non-identical, since dots don't
# always break up netblocks

# eg, 129.24.8.1 would add 1 hit to:
# TODO: put list here!

push(@INC,"/usr/local/lib");
require "bclib.pl";

$all = read_file("sortedips.txt");
unless ($all) {die "No sortedips.txt?";}

for $i (split(/\n/,$all)) {
  $bin = dectobin(
  # convert IP address to binary
  for $j (split(/\./, $i)) {
    $j = unpack("B8",pack("N",$j));
    debug($j);
  }

#  debug($i);
}

=item dectobin($n)

Converts integer $n to a 32-bit binary number (does NOT necessarily
work with 33+-bit numbers).

TODO: this may be inefficient, using pack/unpack is probably better

=cut

sub dectobin {
  my($n) = @_;
  my($res, @res);
  for (1..32) {
    push(@res,$n%2);
    $x=$x>>1;
  }
  $res=join("",reverse(@res));
  return($res);
}
