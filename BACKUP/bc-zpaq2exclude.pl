#!/bin/perl

# Given the output of "zpaq list", outputs data that can be used to
# exclude these files from next backup (via mtime and filename)

# The SQLite3 lines below are experimental

require "/usr/local/lib/bclib.pl";
open(A,">/tmp/bczpaq2exclude.sql");
print A "BEGIN;\n";

while (<>) {
  chomp;
  my($symb, $date, $time, $size, $mode, $file) = split(/\s+/,$_,6);

  # ignroe directories
  if ($mode=~/^d/) {next;}

  # strip directory head (where I rsync stuff)
  $file=~s%/mnt/sshfs/CORPUS/ROOT/%/%;

  unless ($symb eq "-") {
    warn("SKIPPING: $_");
    next;
  }

  # 10 digits because comm requires lexical sort
  my($time) = sprintf("%0.10d", str2time("$date $time UTC"));

  # because I unbzip2/ungzip files, must list all 3 versions of file
  print "$time $file\n";
  print "$time $file.bz2\n";
  print "$time $file.gz\n";

  if ($file=~s/\.tar$/.tbz/) {print "$time $file\n";}

  # just for sqlite3
  $file=~s/\'/''/g;
  print A "INSERT INTO files (mtime, size, filename, backedup) VALUES
 ($time, $size, '$file', 'Y');\n";
}

print A "COMMIT;\n";
close(A);

=item schema

Schema of mysql tables:

CREATE TABLE files (
 mtime INT,
 size INT,
 filename TEXT,
 backedup CHAR(1)
);

CREATE INDEX i1 ON files(mtime,filename);


=cut

