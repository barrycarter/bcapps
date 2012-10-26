#!/bin/perl

# Parses data from directions4me.org

require "/usr/local/lib/bclib.pl";

# TODO: as the name suggests, this is just a temporary list for testing
open(A,"/mnt/sshfs/DIRECTIONSFORME/temp.upc.2");

while (<A>) {
  # correct to full path
  s%^\./%/mnt/sshfs/DIRECTIONSFORME/%;
  debug("FILE: $_");
  $all = read_file($_);

  # go through table rows and cells
  while ($all=~s%<tr.*?>(.*?)</tr>%%is) {
    $row = $1;
    debug("ROW: $row");
    while ($row=~s%<td.*?>(.*?)</td>%%s) {
      # cleanup cell
      $cell = $1;
      $cell = trim($cell);
#      debug("CELL: $cell");
    }
  }

#  debug("ALL: $all");

  if (++$n > 0) {die "TESTING";}

}


