#!/bin/perl

# Given a list of files, find redundant phrases in these files and
# replace them with tokenized shorter phrases. Files are expected to
# be text with no special characters (ie, all chars ASCII 32 - 126
# decimal)

# we use 128-255 only to tokenize for (more efficient if we used 0-31
# and maybe 127 too, but not now)

# we will use 4 7-byte numbers to store, so up to 3 invalid are ok

require "/usr/local/lib/bclib.pl";

# Step 1 (outside this script for now):
# cat files | sort | uniq -c | sort -nr > files.uniq

my($all) = read_file("files.uniq");

# copy I can modify
my($all2) = $all;

# the hash to hold the translations
my(%hash);

# we will use special characters to encode; if file already has
# special characters, note them

# below takes too long, doing it line by line but that adds complications
# while ($all2=~s/([\x7F-\xFF]+)//s) {$hash{$1} = $1;}

# the number for the hash
my($count);

for $i (split(/\n/, $all)) {
  # lines CAN start with spaces, so only one space between count and line
  $i=~/\s*(\d+) (.*)$/;
  my($num,$line) = ($1,$2);

  while ($line=~s/([\x7F-\xFF]+)//) {
    # TODO: must handle this case!
    warn("BAD CHAR: $1");
  }
  debug("$num/$line");
}
