#!/bin/perl

# Given the output of "sha1sum <files>", copy the file to
# /mnt/lobos/FILESBYSHA1 (TODO: genercize this directory) as its
# sha1sum (with two levels of subdirectory)

require "/usr/local/lib/bclib.pl";

my($target) = "/mnt/lobos/FILESBYSHA1";
my(%seen);

# TODO: ignore bad file names
# TODO: check for full path names

while (<>) {

  # the \s+ below *won't* miss files with a leading space since I
  # require full path names

  unless (m%([0-9a-f]{40})\s+(/.*?)$%) {
    warn "BAD LINE: $_";
    next;
  }

  my($sha, $file) = ($1, $2);

  # two level dir path by sha1
  $sha=~m/^(..)(..)/;
  my($dir) = "$target/$1/$2";

  # if target exists, move on
  if (-f "$dir/$sha" || $seen{"$dir/$sha"}) {next;}
  $seen{"$dir/$sha"} = 1;

  # make dir once (since I'm only printing keep track of which dirs
  # I've already printed

  unless (-d $dir || $seen{dir}) {
    print "mkdir -p $dir\n";
    # we only want to print each mkdir once
    $seen{$dir} = 1;
  }

  # and the copy command
  print qq%cp "$file" "$dir/$sha"\n%;
}


