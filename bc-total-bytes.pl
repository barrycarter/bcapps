#!/bin/perl

require "/usr/local/lib/bclib.pl";

# --justfiles: just print out a list of files (ie, for tar --bzip --from-files)

# Given (possibly filtered) output of something like:
# find / -xdev -print0|xargs -0 stat -c "%s %Y %Z %d %i %F %N"
# find the total space used for each file (already given) and each
# directory, including parent directories. The size must be the first
# field and the filename must be enclosed in `quotes' (stat's %N
# format); any other fields are ignored

# NOTE: could've sworn I've written something very similar to this already

my(%size);

while (<>) {

  # TODO: don't ignore symlinks
  if (/ \-> /) {debug("IGNORING SYMLINK: $_"); next;}

  # filename and size
  s/^(\d+)//;
  my($size) = $1;
  # TODO: does this fail on some files?
  s/\`(.*)\'\s*//;
  my($filename) = $1;

  if ($globopts{justfiles}) {print "$filename\n"; next;}

  # to save memory, print file size directly and don't hash it
  print "$size $filename\n";

  # find all ancestor directories
  while ($filename=~s/\/([^\/]*?)$//){$size{$filename}+=$size}
}

for $i (keys %size) {print "$size{$i} $i\n";}
