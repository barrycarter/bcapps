#!/bin/perl

# testing running linear regression

require "/usr/local/lib/bclib.pl";

my($a,$b,$sumy,$list) = linear_regression([1,2,3,4,5],[5,4,3,2,1]);

debug(obtain_weights(1413549897));

debug("ABS: $a $b $sumy");

debug(unfold($list));
