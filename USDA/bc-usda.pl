#!/bin/perl

# converts USDA db to sqlite3, making trivial modifications to mdbtools output

require "/usr/local/lib/bclib.pl";

# input (both the schema AND the data in one swell foop)
# warn("TESTING: remove head -n below");
open(A,"cat /home/barrycarter/BCGIT/USDA/schema.txt; bzcat /home/barrycarter/BCGIT/USDA/data.txt.bz2|");
# output
open(B,">/tmp/usdaq.sql");
# transaction
print B "BEGIN;\n";

while (<A>) {
  chomp;
  # DROP TABLE to DROP TABLE IF EXISTS (to avoid non-fatal warning)
  s/DROP TABLE /DROP TABLE IF EXISTS /isg;
  # kill (xg) for measurements (including leading space in one case)
  # {0,2} below to handle mu and g by itself
  s/\(.{0,2}g\)//isg;
  # below for error in two cases
  s/mg\)//isg;
  # sqlite3 disallows + and * in column names
  s/[\+\*]/_/isg;
  # add semicolons to insert
  if (/^INSERT INTO/) {
    $_="$_;";
    # every so often COMMIT and BEGIN just to catch errors early
    if (rand()<.01) {print B "COMMIT;\nBEGIN;\n";}
  }

  print B "$_\n";
}

print B "COMMIT;\n";

close(A);
close(B);

debug("Finished printing, now running sqlite3 command");

system("rm /tmp/usda.db; sqlite3 /tmp/usda.db < /tmp/usdaq.sql");

