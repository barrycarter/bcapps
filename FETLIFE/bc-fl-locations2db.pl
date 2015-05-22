#!/bin/perl

# attempts to create a fetlife location database (of pure locations
# only, not who lives where) from the data bc-dl-by-region.pl gets
# incidentally

require "/usr/local/lib/bclib.pl";

for $i (glob "/home/barrycarter/FETLIFE/FETLIFE-BY-REGION/*.txt") {

  unless ($i=~/(countries|administrative_areas)\-(\d+)\.txt$/) {
    warn("IGNORING: $i");
    next;
  }

  my(@parent) = ($1,$2);
  my($all) = read_file($i);

  while ($all=~s%/(administrative_areas|cities)/(\d+)\".*?>(.*?)</a>%%is) {
    print "$2:$1:$3:$parent[1]:$parent[0]\n";
  }
}
