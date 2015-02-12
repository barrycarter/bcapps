#!/bin/perl

# Fun w/ Huffman encoding

require "/usr/local/lib/bclib.pl";

# example freq
my($str) = " 7a4e4f3h2i2m2n2s2t2l1o1p1r1u1x1";
my(%freq);

while ($str=~s/^(.)(.)//) {$freq{$1}=$2;}

hash2huffman({%freq});

=item hash2huffman($hashref)

Given a hash of keys and weights, return a huffman encoding

=cut

sub hash2huffman {
  my($hashref) = @_;
  my(%hash) = %$hashref;

  # TODO: sorting each time is uber inefficient
  my(@keys) = sort {$hash{$a} <=> $hash{$b}} keys %hash;

  if ($#keys==0) {return $hashref;}

  my($k1, $k2) = @keys[0..1];

  $hash{"($k1,$k2)"} = $hash{$k1} + $hash{$k2};
  delete $hash{$k1};
  delete $hash{$k2};

  debug("HASH",%hash);

  hash2huffman({%hash});
}


die "ESTING";

# split file into chunks of 4 bytes per line, sort lines, convert \n to space

my($all,$fname) = cmdfile();
$all=~s/\n/ /g;
debug("ALL: $all");

while ($all=~s/^(....)//) {print "$1\n";}

