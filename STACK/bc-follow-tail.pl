#!/bin/perl

open(A,"tail -f $ARGV[0]|");

while (<A>) {
  print $_;
  print "TEST";
}

close(A);
