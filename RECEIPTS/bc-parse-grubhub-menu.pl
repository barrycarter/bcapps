#!/bin/perl

# trivial script to print out the delivery fee given HTML menu

require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {

  my($data) = read_file($i);

  if ($data=~m/class="deliveryFee-variable ">(.*?)</s) {
    print "$i $1\n";
  }
}
