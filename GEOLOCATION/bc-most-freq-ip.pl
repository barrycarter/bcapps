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
  debug("$i ->",ip2bin($i));
}

=item ip2bin($s)

Converts IP address $s (in dotted quad form) to binary.

TODO: this may be inefficient, using pack/unpack is probably better

=cut

sub ip2bin {
  my($s) = @_;
  my($res, @res);

  # split dotted quad, figure out integer value
  my(@split) = split(/\./, $s);
  # TODO: I could write shorter code for below
  my($intval) = $split[0]*256**3+$split[1]*256**2+$split[2]*256+$split[3];

  for (1..32) {
    push(@res,$intval%2);
    $intval=$intval>>1;
  }
  $res=join("",reverse(@res));
  return($res);
}
