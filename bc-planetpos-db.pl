#!/bin/perl

# Trivial script to take the ra/dec approximations in
# db/*-[ra|dec].txt and turn them into a SQLite3 db

push(@INC,"/usr/local/lib");
require "bclib.pl";

for $i (glob "/home/barrycarter/BCGIT/db/*-ra.txt /home/barrycarter/BCGIT/db/*-dec.txt") {
  # what data are we getting?
  $i=~m%/([^/]*?)-approx-(.*?)\.txt%;
  ($planet, $which) = ($1,$2);

  # read the file (all are small)
  @data = split(/\n/,read_file($i));

  # split each data line
  for $i (@data) {
    ($t, $y, $s) = split(/\ /, $i);
    # insert statement
    push(@queries, "INSERT INTO planetpos (time, type, planet, xinit, slope)
VALUES ('$t', '$which', '$planet', '$y', '$s')");
  }
}

# debug(@queries);

# db schema
$dbcreate = << "MARK";
DROP TABLE IF EXISTS planetpos;
CREATE TABLE planetpos (time DOUBLE, type, planet, xinit DOUBLE, slope DOUBLE);
CREATE INDEX itime ON planetpos(time);
CREATE INDEX itype ON planetpos(type);
CREATE INDEX iplanet ON planetpos(planet);
BEGIN;

MARK
;

# print schema and queries to db/planetpos.db

open(A,"|sqlite3 /home/barrycarter/BCGIT/db/planetpos.db");
# open(A,">/tmp/debug.txt");

print A $dbcreate;
print A join(";\n", @queries);
print A ";\nCOMMIT;\n";

close(A);


