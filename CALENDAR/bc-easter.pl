#!/bin/perl

# Computes Easter, Lent, Shrove Thursday, Ash Wednesday, Mardi Gras,
# plus a bunch of really useless stuff

require "/usr/local/lib/bclib.pl";

computeEaster(2014);

# TODO: document and put into bclib.pl

sub computeEaster {
  my($year) = @_;
  my(%rethash);

  # dominical letter (as number)
  my($jan1day) = (str2time("$year-01-01 12:00:00 UTC")/86400-3)%7;
  debug("J1D: $jan1day");
}
