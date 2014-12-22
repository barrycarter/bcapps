#!/bin/perl

# creates a tarfile of files I need to backup weekly, but also notes
# which files haven't changed in a while and suggests "perma" backing
# them up, instead of backing them up weekly

require "/usr/local/lib/bclib.pl";

my($dir) = "/usr/local/etc/weekly-backups/files";
$now = time();

# TODO: reduce or eliminate cache time
my($out,$err,$res) = cache_command2("find -L /usr/local/etc/weekly-backups/files -ls", "age=43200");

open(A, ">/tmp/btw-chunk1.txt");

my($tot,$num) = (0,1);

for $i (split(/\n/, $out)) {
  # kill leading spaces
  $i=~s/^\s+//g;

  # TODO: I can probably do this better
  my(@arr) = split(/\s+/, $i);
#  debug("ARR",@arr);
  my($ino, $bsize, $perms, $nlinks, $user, $group, $size, $d1, $d2, $d3) =
    splice(@arr, 0, 10);

  # TODO: in theory, could omit directories with "-type f" at "find"
  # level, but worry about descending into directories with -L option?
  if ($perms=~/^d/) {next;}

  # TODO: this can theoretically be inaccurate
  my($fname) = join(" ",@arr);

  # TODO: order files somehow?

  # convert to unix
  my($age) = $now-str2time("$d1 $d2 $d3");

  # ignore younger than one month (for now)
  if ($age < 365.2425/12*86400) {next;}

  # add sizes until we hit 1G uncompressed
  $tot+= $size;

  # over 1G? new chunk + reset
  if ($tot>1e+9) {
    close(A);
    $num++;
    debug("Opening new chunk: $num");
    open(A,">/tmp/btw-chunk$num.txt");
    $tot=0;
  }

  # write to file
  print A "$fname\n";
}

close(A);


