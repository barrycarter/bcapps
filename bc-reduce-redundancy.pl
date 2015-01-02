#!/bin/perl

# Given a list of files, find redundant phrases in these files and
# replace them with tokenized shorter phrases. Files are expected to
# be text with no special characters (ie, all chars ASCII 32 - 126
# decimal)

# we use 128-255 only to tokenize for (more efficient if we used 0-31
# and maybe 127 too, but not now)

require "/usr/local/lib/bclib.pl";

# Step 1 (outside this script for now):
# cat files | sort | uniq -c | sort -nr > files.uniq

$all = read_file("files.uniq");

if ($all=~/[\x7F-\xFF]/) {
  die ("Files contain character in invalid range");
}

die "TESTING";

for $i (split(/\n/, read_file("files.uniq"))) {
  debug("I: $i");
}
