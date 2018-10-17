#!/bin/perl

# Trivial script: given a list of getmail log files, find last time
# mail successfully downloaded (0 message downloads don't count) +
# order by date

require "/usr/local/lib/bclib.pl";

my(%date);

for $i (@ARGV) {

  open(A, "tac $i|");
  $date{$i} = "0000-00-00 00:00:00";

  while (<A>) {
    if (/^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\s+(\d+) messages\s*\(\d+ bytes\)\s* retrieved/ && $2>0) {
      $date{$i} = $1;
      last;
    }
  }
}

for $i (sort {$date{$b} cmp $date{$a}} keys %date) {
  print "$i: $date{$i}\n";
}
