#!/bin/perl

# TODO: since switching to MySQL, I probably don't need to use this at all

# To prevent race conditions, some of my programs will now write
# queries to /var/tmp/queries with filename
# "YYYYMMDD.HHMMSS.NNNNNNNNN-dbname-pid" where N* = time down to the
# nanosecond; this trivial script processes those queries in time
# order (for a given db, to avoid one db update delaying another)

# --append: run commands in this file after each file

# NOTE: this only works if ALL programs using a given db use this method.

# TODO: the "DONE" directory should be wiped regularly

require "/usr/local/lib/bclib.pl";
$globopts{debug} = 1;
my($db)=shift||die("Usage: $0 name_of_db_without_.db");

# this program is intended to avoid race conditions, so must only run once
unless (mylock("bc-query-gobbler-$db.pl","lock")) {exit(0);}

dodie('chdir("/var/tmp/querys")');

for $i (sort(glob("*$db*"))) {

  unless ($i=~/^\d{8}\.\d{6}\.\d{9}\-$db/) {next;}
  debug("GOBBLING: $i");

  # find db
  $i=~/^[\d\.]+\-([a-z]+)/||warn("BAD I: $i");
  my($db) = $1;

  # experimentally, write data to MySQL db too
  # if madis, run on mysql too
  if ($db eq "madis") {
    system("mysql madis < $i 1> mysql.$db.out 2> mysql.$db.err");
    system("mysql madis < /usr/local/etc/madis-my.sql");
    system("mv $i DONE");
    warn("Updating MySQL only, not SQLite3");
    next;
  }

  # TODO: in theory, could group all files for one db together
  # copy to new version, run queries, move back safely

  # /var/tmp/querys is now on RAMDISK, so copying db locally to avoid
  # disk throttling

  $cmd = "cp /sites/DB/$db.db $db.db.new; nice -n 19 sqlite3 $db.db.new < $i 1> $db.out 2> $db.err";
  debug("RUNNING: $cmd");
  system($cmd);

  if ($globopts{append}) {
    $cmd = "nice -n 19 sqlite3 $db.db.new < $globopts{append}";
    debug("RUNNING: $cmd");
    system($cmd);
  }

  # integrity check
  $cmd = "sqlite3 $db.db.new 'pragma integrity_check'";
  debug("RUNNING: $cmd");
  my($res) = system($cmd);
  if ($res) {
    warn "$db.db.new corrupt, ignoring";
    write_file("$db corrupt", "/home/barrycarter/ERR/bcinfo3.$db.err");
    next;
  }

  # db not corrupt, so erase any previous errors
  write_file("", "/home/barrycarter/ERR/bcinfo3.$db.err");

  # mv cross sytem boundaries is not instant, so must do it this way
  $cmd = "mv $db.db.new /sites/DB/; mv /sites/DB/$db.db /sites/DB/$db.db.old; mv /sites/DB/$db.db.new /sites/DB/$db.db";
debug("RUNNING: $cmd");
  system($cmd);

  # TODO: error check
  # move file to "DONE"
  system("mv $i DONE");
}

mylock("bc-query-gobbler-$db.pl","unlock");
