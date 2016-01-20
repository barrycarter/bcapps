#!/bin/perl

require "/usr/local/lib/bclib.pl";

while (<>) {

  chomp;
  my(@data) = split(/\s+/, $_);
  map(s/[h\s]//g, @data);
  my($ck) = hex(pop(@data));
#  debug("DATA", @data);

  my(@test) = (32,16,8,4,2,1);

  # note that this is NOT hex(string) because two digit pairs (base
  # 256) are treated as a single number

  $sum = 0;
  for $i (0..$#test) {
    $sum += (-1)**($i+1)*$test[$i]*hex($data[$i]);
#    $sum += $test[$i]*hex($data[$i]);
  }


  $sum += -114;

  $sum = $sum%256;

  debug("SUM($_): $sum vs $ck");

}
