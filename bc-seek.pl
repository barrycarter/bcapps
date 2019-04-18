#!/bin/perl

# $0 filename b s
# seeks into a given file and returns bytes b through b+s

my($fname, $b, $s) = @ARGV;

open(A, $fname)||die("Can't open $fname, $!");

sysseek(A, $b, 0)||die("Can't seek to byte $b, $!");

sysread(A, $d, $s)||die("Can't sysread, $!");

print "$d";

