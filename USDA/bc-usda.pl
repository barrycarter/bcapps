#!/bin/perl

# converts USDA db to sqlite3, making trivial modifications to mdbtools output

require "/usr/local/lib/bclib.pl";

# input (both the schema AND the data in one swell foop)
warn("TESTING: remove head -n below");
open(A,"cat /home/barrycarter/BCGIT/USDA/schema.txt; bzcat /home/barrycarter/BCGIT/USDA/data.txt.bz2| head -100|");
# output
open(B,">/tmp/usdaq.sql");
# transaction
print B "BEGIN;\n";

while (<A>) {

  # DROP TABLE to DROP TABLE IF EXISTS (to avoid non-fatal warning)
  s/DROP TABLE /DROP TABLE IF EXISTS /isg;

  # removing all parens (excessive?)
#  s/[\(\)]//isg;

  debug("THUNK: $_");
  print B $_;
}

print B "COMMIT;\n";

close(A);
close(B);

system("rm /tmp/usda.db; sqlite3 /tmp/usda.db < /tmp/usdaq.sql");

