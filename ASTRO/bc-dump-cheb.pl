#!/bin/perl

# similar to bc-read-cheb.pl but dumps positional data by cleverly
# evaulating Chebyshev polynomials only at specific points

require "/usr/local/lib/bclib.pl";

for $file (glob("/home/barrycarter/SPICE/KERNELS/asc[pm]*.bz2")) {
  # much of this code is from bc-read-cheb.pl
  open(A,"bzcat $file|");
  my(@data) = ();

  # 341 lines per chunk
  while (<A>) {
    for (1..341) {push(@data,scalar(<A>));}
  }

  debug("DATA",@data);

}


