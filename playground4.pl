#!/bin/perl

# testing running linear regression

require "/usr/local/lib/bclib.pl";

my(%hash) = obtain_weights(1413549897);

for $i (sort {$b<=>$a} keys %hash) {
  # compute day and assign (backwards so older trumps newer)
  # -.25 = 6 hours = correct during MDT, close enough during MST
  # actually 3am = "cutoff time"
  $day = floor(($i/86400)-.375);
  $weight{$day} = $hash{$i};
}

# still backwards

for $i (sort {$b <=> $a} keys %weight) {
  push(@keys, $count++);
  push(@vals, $weight{$i});
}

my($a,$b,$sumy,$list) = linear_regression(\@keys, \@vals);

@list = @{$list};

while (@list) {
  my($a,$b) = splice(@list,0,2);
  debug("$days/$a/$b");
  $days++;
}



