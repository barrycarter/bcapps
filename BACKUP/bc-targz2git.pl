#!/bin/perl

# I have backups of multiple wp blogs in a format used by softaculous
# which has files names like: (wp|mw).xx_xxxxx.yyyy-mm-dd_hh-mm-ss.tar.gz
# where the x's are digits (the last 5 are probably PID)

# the backups are almost identical, but not identical enough for sha1
# to catch dupes; instead, this program untars them into a git
# directory (pre-initialized with "git init ." and does commits so
# only the diffs are stored

# NOTE: softaculous appears to try to backup the tar file itself so
# this may be more broken than I think

require "/usr/local/lib/bclib.pl";

# where the GIT repo is

my($git) = "/home/user/BACKUP/GIT";

my(%dates);

# collect by date

while (<>) {

  chomp;

  # make sure its a file
  unless (-f $_) {
    warn "$_ is not a file";
    next;
  }

  # assign names to the elts

  my($name1, $num1, $num2, $date, $time, $tar, $gz) = split(/[\._]/, $_);

  # the blogs full "name" is "$name1$num1$num2", though that may not
  # be relevant yet

  # sanity check

  unless ($tar eq "tar" && $gz eq "gz") {warn("BAD SUFFIX: $_"); next;}
  unless ($num1=~/^\d+$/) {warn "BAD NUM1: $_"; next;}
  unless ($num2=~/^\d+$/) {warn "BAD NUM2: $_"; next;}
  unless ($date=~/^\d{4}\-\d{2}\-\d{2}$/) {warn "BAD DATE: $_"; next;}
  unless ($time=~/^\d{2}\-\d{2}\-\d{2}$/) {warn "BAD TIME: $time in $_"; next;}

#  debug("GOT: $name1, $num1, $num2, $date, $time, $tar, $gz");

  # add this file name to list for given day (we will parse later)

  push(@{$dates{$date}}, $_);

}

# sort by date order (this makes this sort of a one off, icky)

for $i (sort keys %dates) {
  for $j (@{$dates{$i}}) {
    debug("I: $i, J: $j");
  }
}


