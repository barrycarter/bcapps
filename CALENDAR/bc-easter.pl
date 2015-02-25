#!/bin/perl

# Computes Easter, Lent, Shrove Thursday, Ash Wednesday, Mardi Gras,
# plus a bunch of really useless stuff

require "/usr/local/lib/bclib.pl";

for $i (2015..2037) {
  computeEaster($i);
}

# TODO: document and put into bclib.pl

sub computeEaster {
  my($year) = @_;
  my(%rethash);

  # golden number
  my($gn) = ($year%19)+1;
  # epact (for 2000-2099 only)
  my($epact) = (11*($gn-1)-1)%30;

  # dominical letter (as number) for January
  my($dl) = (3-str2time("$year-01-01 12:00:00 UTC")/86400)%7+1;
  # this only works for 2000-2099; dominical letter for March onwards
  if ($year%4==0) {$dl = ($dl-2)%7+1;}



  debug("$year ".chr(64+$dl));
}
