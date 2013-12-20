#!/bin/perl

# tried to make this an alias (find all tags in my todo list), but
# quoting killed me

# Given a regex, finds and prints all instances of strings in STDIN
# matching regex, one per line

# does not use bclib.pl, would be a pointless require

while (<STDIN>) {while (s/($ARGV[0])//) {print "$1\n";}}
