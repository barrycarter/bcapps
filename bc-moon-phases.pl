#!/bin/perl

# Loads db/moon-phases-* into SQLite3 db

require "bclib.pl";

for $i (glob "/home/barrycarter/BCGIT/db/moon-phases*") {
  $all = read_file($i);
  for $j (split(/\n/, $all)) {
    @fields = csv($j);
    # ignore header lines
    if ($fields[2]=~/phase/) {next;}

    # fields 2 and 4 are phase and time/date of phase
    print "$fields[2]\t$fields[4]\n";
  }
}

=item schema

Schema for SQLite3 table and commands to fill it

CREATE TABLE moonphases (phase TEXT, time DATE);
.separator \t
.import /tmp/phases.txt abqastro

=cut
