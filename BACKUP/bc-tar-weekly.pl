#!/bin/perl

# creates a tarfile of files I need to backup weekly, but also notes
# which files haven't changed in a while and suggests "perma" backing
# them up, instead of backing them up weekly

require "/usr/local/lib/bclib.pl";

my($dir) = "/usr/local/etc/weekly-backups/files";
$now = time();

# TODO: reduce or eliminate cache time
my($out,$err,$res) = cache_command2("find -L /usr/local/etc/weekly-backups/files -ls", "age=43200");

debug("OUT: $out");

for $i (split(/\n/, $out)) {
  # kill leading spaces
  $i=~s/^\s+//g;

  # TODO: I can probably do this better
  my(@arr) = split(/\s+/, $i);
  my($ino, $bsize, $perms, $nlinks, $user, $group, $size, $d1, $d2, $d3) =
    splice(@arr, 0, 10);
  # TODO: this can theoretically be inaccurate
  my($fname) = join(" ",@arr);

  # convert to unix
  my($age) = $now-str2time("$d1 $d2 $d3");
#  debug("$d1 $d2 $d3 -> $age");

  # older than one month? then print
  if ($age > 365.2425/12*86400) {print "$fname\n";}

  #  debug("LEFT",@arr);
  #  debug("$d1 $d2 $d3");
}


