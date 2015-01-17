#!/bin/perl

require "/usr/local/lib/bclib.pl";

# --justfiles: just print out a list of files (ie, for tar --bzip --from-files)

# Altered to use the output of: stat -c "%s %Y %Z %d %i %n"

# TODO: generalize this

# Given the (possibly filtered) output of "find [...] -ls", find the
# total space used for each file (already given) and each directory,
# including parent directories

# NOTE: could've sworn I've written something very similar to this already

my(%size);

# list of fields, except filename which must be last due to spaces
my(@format) = ("size", "mtime", "ctime", "devno", "inode");

while (<>) {

  # cleanup
#  s/^\s*(.*?)\s*$/$1/;

  my(%hash) = ();
  my(@data) = split(/\s+/, $_);

  for $i (@format) {$hash{$i} = shift(@data);}

  # this assumes filenames are split by single spaces = bad?
  my($file) = join(" ",@data);

  if ($globopts{justfiles}) {
    # if just printing, remove backslashes
    $file=~s/\\//g;
    print "$file\n";
    next;
  }

  debug("$file $hash{size}");

  # to save memory, print file size directly and don't hash it
  print "$hash{size} $file\n";
  

  # find all ancestor directories
  while ($file=~s/\/([^\/]*?)$//) {$size{$file} += $hash{size}}
}

for $i (keys %size) {print "$size{$i} $i\n";}


