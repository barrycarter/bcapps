#!/bin/perl

# given a list of files that may have bz2'd equivalents, compare sha1
# of file and its bzip2 equivalent and recommend deletion of original
# unbzip2'd file if they are identical

require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {

  # if no compressed version, dont care

  unless (-f "$i.bz2") {next;}

  # sha1 of bz2 version

  my($out, $err, $res) = cache_command2("bzcat $i.bz2 | sha1sum");

  $out=~s/\s+.*$//;

  $bzsha = trim($out);

  ($out, $err, $res) = cache_command2("sha1sum $i");

  $out=~s/\s+.*$//;

  $origsha = trim($out);

  if ($origsha eq $bzsha) {
    print "rm $i\n";
  }

}
