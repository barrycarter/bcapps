#!/bin/perl

# Given the first pages of several fetlife groups, download all other
# pages (and, later, every message as well)

# TODO: individual posts may have multiple pages too...

require "/usr/local/lib/bclib.pl";

chdir("/home/barrycarter/20140821/groups");

# rapid way to get page list
my($out,$err,$res) = cache_command2("fgrep page= *", "age=3600");

for $i (split(/\n/, $out)) {
  $i=~s/^(\d+):(.*)$//||warn("BAD LINE: $i");
  $data{$1} = $2;
}

# this file contains groups in most-to-least popular order
@groups = split(/\n/, read_file("groups.txt"));

for $i (@groups) {
  my($maxpage) = 0;
  while ($data{$i}=~s/page=(\d+)//) {
    if ($1>$maxpage) {$maxpage=$1;}
  }

  # URLs to dl all pages (no curl commands, since I need _fl_sessioid cookie)
  for $j (1..$maxpage) {
    print "'https://fetlife.com/groups/$i?page=$j'\n";
  }
}


