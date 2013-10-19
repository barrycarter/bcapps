#!/bin/perl

# converts an sqlite3 dump to a MySQL style dump (trivial)
# indexes on text columns will not convert over

require "/usr/local/lib/bclib.pl";

while (<>) {
  s/INSERT INTO \"(.*?)\"/INSERT INTO $1/;
  if (/^PRAGMA/) {next;}
  s/^BEGIN TRANSACTION/BEGIN/;
  print $_;
}

