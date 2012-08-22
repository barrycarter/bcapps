#!/bin/perl

# Does what bc-seek-help.pl does, but for facebook

require "/usr/local/lib/bclib.pl";

# using the watermelon example
my($cmd) = "curl -N -s 'https://graph.facebook.com/search?q=watermelon&type=post'";

open(A,"$cmd|");

while (<A>) {
  debug("THUNK: $_");
}


