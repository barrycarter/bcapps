#!/bin/perl

# Calculates conquerculb odds that appear to be different from Risk odds

# a1 = attacker's 1st die, d1 = defender's 1st die
for $a1 (1..6) {
  for $a2 (1..6) {
    for $a3 (1..6) {
      for $d1 (1..6) {
	for $d2 (1..6) {
	  # reset attackers and defenders losses
	  ($aloss,$dloss) = (0,0);

	  # sort rolls in order
	  # <h>I'm too lazy to do sort {$b <=> $a}</h>
	  @a = reverse(sort($a1,$a2,$a3));
	  @d = reverse(sort($d1,$d2));

	  # compare the highest dice (>= below since defender wins ties)
	  if ($d1 >= $a1) {$aloss++;} else {$dloss++;}
	  # compare the 2nd highest dice (>= below since defender wins ties)
	  if ($d2 >= $a2) {$aloss++;} else {$dloss++;}
	  # print result
	  print "A: $aloss, D: $dloss\n";
	}
      }
    }
  }
}

# Send the output of this program to sort | uniq -c
