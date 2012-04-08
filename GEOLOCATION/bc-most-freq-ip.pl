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

open(A,">ipfreq.txt");

for $i (split(/\n/,$all)) {
  $bin = ip2bin($i);
  # add IP address to each block it belongs to (16 blocks in total?)
  for $i (1..32) {$net{substr($bin,0,$i)}++;}
}

# which netblocks have most IPs (obviously either '1' or '0' will have most)
@blocks = sort {$net{$b} <=> $net{$a}} (keys %net);

for $i (@blocks) {
  # ignore blocks w single IP
  if ($net{$i}<2) {next;}

  # convert "01" to 64.0.0.0/2 for example
  $len = length($i);

  # pad to 32 bits
  $ip=substr($i."0"x32,0,32); # pad to 32 bits
  # convert to IP form
  $ip=~/^(.{8})(.{8})(.{8})(.{8})$/||die("BAD STRING: $i");
  $ip=join(".",ord(pack("B8",$1)),ord(pack("B8",$2)),ord(pack("B8",$3)),ord(pack("B8",$4)));
  # and print
  print A "$ip/$len: $net{$i}\n";
}

close(A);

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
