#!/bin/perl

# similar to bc-read-cheb.pl but dumps positional data by cleverly
# evaulating Chebyshev polynomials only at specific points

require "/usr/local/lib/bclib.pl";

open(A,"bzcat /home/barrycarter/SPICE/KERNELS/asc[pm]*.bz2|");

while (!eof(A)) {
  chomp;
  my($data) = "";
  # <h>this code should be taken out and shot</h>
  for (1..341) {$data.=<A>;}
  my(@data) = split(/\s+/s, $data);
  # TODO: first chunk should be blank!
  debug("DATA:",@data);

}




