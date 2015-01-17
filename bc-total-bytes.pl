#!/bin/perl

require "/usr/local/lib/bclib.pl";

# --justfiles: just print out a list of files (ie, for tar --bzip --from-files)

# TODO: generalize input format

# Given (possibly filtered) output of something like:
# find / -xdev -print0|xargs -0 stat -c "%s %Y %Z %d %i %F %N"
# find the total space used for each file (already given) and each
# directory, including parent directories

# NOTE: could've sworn I've written something very similar to this already

my(%size);

# list of fields, except %F and %N which can have spaces
my(@format) = ("size", "mtime", "ctime", "devno", "inode");

while (<>) {

  my(%hash) = ();
  my(@data) = split(/\s+/, $_);

  for $i (@format) {$hash{$i} = shift(@data);}

  # rest of data is file type and file name (ignoring symlinks)
  for $i (@data) {
    if ($i=~/^\`(.*?)\'$/) {$hash{filename} = $1; last;}
    # this catenates filetype into a single word
    $hash{type}.=$i;
  }


  if ($globopts{justfiles}) {print "$hash{filename}\n"; next;}

  # to save memory, print file size directly and don't hash it
  print "$hash{size} $hash{filename}\n";

  # find all ancestor directories
  while ($hash{filename}=~s/\/([^\/]*?)$//){$size{$hash{filename}}+=$hash{size}}
}

for $i (keys %size) {print "$size{$i} $i\n";}
