#!/bin/perl

# To prevent race conditions, some of my programs will now write
# queries to /var/tmp/queries with filename
# "YYYYMMDD.HHMMSS.NNNNNNNNN-dbname-pid" where N* = time down to the
# nanosecond; this trivial script processes those queries in time order

# --vacuum: vacuum the database after running queries

# NOTE: this only works if ALL programs using a given db use this method.

# TODO: the "DONE" directory should be wiped regularly

require "/usr/local/lib/bclib.pl";

dodie('chdir("/var/tmp/querys")');

for $i (sort(glob("*"))) {
  # ignore the DONE directory
  if ($i eq "DONE") {next;}
  # find db
  $i=~/^[\d\.]+\-([a-z]+)/||warn("BAD I: $i");
  my($db) = $1;

  # TODO: in theory, could group all files for one db together
  # copy to new version, run queries, move back safely
  system("cp /sites/DB/$db.db /sites/DB/$db.db.new; sqlite3 /sites/DB/$db.db.new < $i");

  # experimentally, write data to MySQL db too
#  system("bc-sqlite3dump2mysql.pl < $i | mysql shared");

  if ($globopts{vacuum}) {system("echo 'VACUUM;' | sqlite3 /sites/DB/$db.db.new");}

  system("mv /sites/DB/$db.db /sites/DB/$db.db.old; mv /sites/DB/$db.db.new /sites/DB/$db.db");

  # TODO: error check
  # move file to "DONE"
  system("mv $i DONE");
}

