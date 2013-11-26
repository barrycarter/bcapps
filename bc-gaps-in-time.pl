#!/bin/perl

# This script, useful for me only, looks at a file whose leftmost
# entries are "hhmmss" and finds the largest gaps

require "/usr/local/lib/bclib.pl";
my($all,$name) = cmdfile();

for $i (split(/\n/, $all)) {
  $i=~s/\s+.*$//;
  if ($i=~/^\s*$/) {next;}

  unless ($i=~/^(\d{2})(\d{2})(\d{2})$/) {warn "ERROR: $i"; next;}
  $j = $1+$2/60+$3/3600;
  my(%hash) = ();
  $hash{gap} = $j-$last;
  $hash{label} = "$lasti - $i";
  push(@gaps, {%hash});
  $last = $j;
  $lasti = $i;
}

for $i (sort {$b->{gap} <=> $a->{gap}} @gaps) {
  print "$name: $i->{label} $i->{gap}\n";
}



