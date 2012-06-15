#!/bin/perl

# given the output of "sha1sum <files> | sort", find duplicates and suggest
# deletion, potentially based on a given rule

# NOTE: this is inefficient and doesn't take advantage of the fact the
# input is sorted

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

  # hideous hardcoding
  if ($files[1] eq "$files[0].mobi") {
    print "rm $files[0]\n";
  }
  debug("FILES($i)",@files);
}
  

