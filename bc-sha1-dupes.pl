#!/bin/perl

# given the output of "sha1sum <files> | sort", find duplicates and suggest
# deletion, potentially based on a given rule

# NOTE: this is inefficient and doesn't take advantage of the fact the
# input is sorted

# TODO: add an option that linkifies to base document

require "/usr/local/lib/bclib.pl";

while (<>) {
  m/^(.*?)\s+(.*?)$/;
  ($sha, $file) = ($1, $2);
  $match{$sha}{$file} = 1;
}

for $i (sort keys %match) {
  # all files for this sha1
  @files = sort keys %{$match{$i}};

  # if only 1, no dupes
  unless ($#files) {next;}

  debug("BASEFILE: $files[0]");

  # print out all but the first
  for $j (1..$#files) {print "$files[$j]\n";}

}
