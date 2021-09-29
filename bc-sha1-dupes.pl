#!/bin/perl

# given the output of "sha1sum <files> | sort", find duplicates and suggest
# deletion, potentially based on a given rule

# NOTE: this is inefficient and doesn't take advantage of the fact the
# input is sorted

# TODO: add an option that linkifies to base document

require "/usr/local/lib/bclib.pl";

warn "Ignoring files less than 100K bytes";

while (<>) {
  m/^(.*?)\s+(.*?)$/;
  ($sha, $file) = ($1, $2);
  $match{$sha}{$file} = 1;
}

for $i (sort keys %match) {

  # all files for this sha1
  @files = sort {length($a) <=> length($b)} keys %{$match{$i}};

  # if only 1, no dupes
  unless ($#files) {next;}

  # this slows things down a bit
  my($size) = -s $files[0];

  if ($size < 100000) {next;}

  debug("$size BASEFILE: $files[0] of and $files[1]");

  print "echo \"$files[0]\"\n";

  # print out all but the first
  for $j (1..$#files) {
    print "rm \"$files[$j]\"\n";
    print "ln -s \"$files[0]\" \"$files[$j]\"\n";
  }

}
