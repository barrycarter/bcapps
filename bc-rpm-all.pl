#!/bin/perl

# Obtain all querytags information from given RPM file

# TODO: allow package specification as -ql not just -qpl ?

require "/usr/local/lib/bclib.pl";

my(@tags) = `rpm --querytags`;

my(@query);

for $i (@tags) {
  chomp($i);
  push(@query, "$i: %{$i}\\n");
}

my($query) = join(" ",@query);

# TODO: just for testing
# TODO: this does NOT list files in package
my($cmd) = "rpm -qa --queryformat '$query' -q wget";

print "$cmd\n";

