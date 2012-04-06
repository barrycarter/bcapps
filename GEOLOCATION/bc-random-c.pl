#!/bin/perl

# Generates '''random''' addresses in EVERY "class C" network, with the
# intent of hitting every major ISP; of course, we now use CIDR, so
# "class C" is meaningless

push(@INC,"/usr/local/lib");
require "bclib.pl";

for $i (0..255) {
  for $j (0..255) {
    for $k (0..255) {
      $l = int(rand()*256);
      # sorting by this random number will randomize the entries later
      $rand = rand();
      print "$rand mtr -rwc 1 $i.$j.$k.$l >> /var/tmp/mtr-$i.txt\n";
    }
  }
}
