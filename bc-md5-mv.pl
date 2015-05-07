#!/bin/perl

# Given the md5 sums of two sets of files (in presumably different
# directories, and in either MAC OS X or UNIX format), print (but
# don't run) mv commands that would give files in set2 the same name
# as their equivalents in set1

require "/usr/local/lib/bclib.pl";

my(@set) = @ARGV;
my(%files);

for $i (0..1) {

  my($data) = read_file($set[$i]);
  my($file,$hash);

  for $j (split(/\n/,$data)) {

    # get filename and hash
    if ($j=~/^MD5 \((.*)\) = ([0-9a-f]{32})$/) {
      ($file, $hash) = ($1,$2);
    } elsif ($j=~/^([0-9a-f]{32})\s+(.*)$/) {
      ($file, $hash) = ($2, $1);
    } else {
      warn("BAD LINE: $j");
      next;
    }

    # and store
    $files{$hash}{$i} = $file;
  }
}

for $i (keys %files) {

  # this may be the ugliest bit of programming ever
  @f = (0,1);
  map($_=$files{$i}{$_},@f);

  # if either set doesnt have this hash, move on
  unless ($f[0] && $f[1]) {next;}
  # if both have but already identical, ignore
  if ($f[0] eq $f[1]) {next;}

  print qq%mv -n "$f[0]" "$f[1]"\n%;
}
