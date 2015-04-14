#!/bin/perl

# given a file with the (unsorted) output of sha1sum, list duplicate files
# fairly trivial to write

# "bc-dupe-checker.pl sha1file | xargs ls -l | sort -k5nr" helpful in
# finding large duplicates

# this does exactly? what bc-sha1-dupes.pl does, but perhaps more dangerously

push(@INC, "/usr/local/lib");
require "bclib.pl";
$dir = tmpdir();

system("sort $ARGV[0] > $dir/sha1sorted.txt");
$sha1s = read_file("$dir/sha1sorted.txt");

for $i (split(/\n/, $sha1s)) {
  # confirm the line is really sha1 or md5 followed by filename
  unless ($i=~/^([0-9a-f]{32})\s+(.*)$/ || $i=~/^([0-9a-f]{40})\s+(.*)$/) {
    warnlocal("BAD LINE: $i");
    next;
  }

  # otherwise, record sha1 and filename
  ($sha1, $file) = ($1, $2);

  # are we seeing the same sha1 again?
  if ($sha1 eq $cur) {
#    print qq%"$file";: $cur\n%;
    print qq%"$file"\n%;
    next;
  }

  # not a match, so this is the new current
  $cur = $sha1;

#  debug("I: $i");
}

