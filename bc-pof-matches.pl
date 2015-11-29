#!/bin/perl

# After using http://www.pof.com/basicsearch.aspx and saving all the
# pages (which can be done w/ a macro) to files like 20151123-1.htm,
# this program goes through the files in numerical order (to preserve
# pof's sorting) and prints out uniq ids (in order)

# these ids can then be pruned to remove already-contacted persons and
# the result can be fed into a macro to contact persons meeting the
# search who have not yet been contacted

# TODO: this current just loops through files in *given* order (so
# something like "$0 20151123-?.html 20151123-??.html" to preserve
# order), and does NOT sort the files in "proper" order

require "/usr/local/lib/bclib.pl";

while (<>) {
  unless (/profile_id=(\d+)/) {next;}
  while (s/profile_id=(\d+)//) {
    my($id) = $1;
    if ($seen{$id}) {next;}
    print "$id\n";
    $seen{$id} = 1;
  }
}

