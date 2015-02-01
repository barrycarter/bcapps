#!/bin/perl

require "/usr/local/lib/bclib.pl";

# --justfiles: just print out a list of files (ie, for tar --bzip --from-files)
# --altformat: format that excludes device number (for external drives?)

# TODO: generalize input format

# Given (possibly filtered) output of something like:
# find / -xdev -print0|xargs -0 stat -c "%s %Y %Z %d %i %F %N"
# find the total space used for each file (already given) and each
# directory, including parent directories

# NOTE: could've sworn I've written something very similar to this already

my(%size);

# list of fields, except %F and %N which can have spaces

my(@format);
if ($globopts{altformat}) {
  @format = ("size", "mtime", "ctime", "inode");
} else {
  @format = ("size", "mtime", "ctime", "devno", "inode");
}

while (<>) {

  my(%hash) = ();

  for $i (@format) {
    s/\s*(\d+)\s*//;
    $hash{$i} = $1;
  }

  # type and name (ignoring symlink targets for now)
  s/\s*(.*?)\s*\`/\`/;
  $hash{type} = $1;
  # TODO: does this fail on files with embedded apostrophes?
  s/\`(.*?)\'\s*//;
  $hash{filename} = $1;

  if ($thunk && !($thunk=~/\->\s/)) {warn("BAD THUNK: $_");}

  # convert true apos back
  $hash{filename}=~s/\x01/\'/g;

  if ($globopts{justfiles}) {print "$hash{filename}\n"; next;}

  # to save memory, print file size directly and don't hash it
  print "$hash{size} $hash{filename}\n";

  # find all ancestor directories
  while ($hash{filename}=~s/\/([^\/]*?)$//){$size{$hash{filename}}+=$hash{size}}
}

for $i (keys %size) {print "$size{$i} $i\n";}
