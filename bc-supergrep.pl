#!/bin/perl

# A wrapper around grep that searches more the way I want:

# Usage: $0 phrase1 phrase2 phrase3 ... file1 file2 file3 ...

# Does "grep -i phrase1 file1 file2 file3 | grep -i phrase2 | grep -i phrase3"

# In other words, does case-insensitive searching of multiple not
# necessarily adjacent phrases in multiple files (the delination
# between phrases and files is based on whether the given argument is
# an existing file or not).

# Additionally, supports the "include" protocol: if a file "includes"
# another file, the included file is grepped as well, recursively

# TODO: not crazy about "##include 'full-path-to-filename'" as include protocol

require "/usr/local/lib/bclib.pl";

my($fileq) = 0;

# parse arguments until we find a file

for $i (@ARGV) {

  # is it a file
  if (-f $i) {
    # if fileq not set, set it
    $fileq = 1;
    push(@files,$i);
    next;
  }

  # not a file
  if ($fileq) {die "Have already seen a file, no more phrases allowed!";}

  push(@phrases,$i);
}

# search for inclusions (allowing for recursion and self-looping)

for $i (@files) {
  my(@incs) = `egrep '^## include \' $i`;
  for $j (@incs) {
    $j=~s/\"(.*?)\"//;
    # TODO: need to use hash here to allow for recursion and looping
    push(@files,$1);
  }
}

my($files) = join(" ",@files);

# construct fgrep chain; first phrase is normal grep
my($fphrase) = shift(@phrases);
my($cmd) = "fgrep -i '$fphrase' $files";

# other phrases as piped greps
for $i (@phrases) {
  $cmd .= "|fgrep -i '$i'";
}

debug($cmd);
system($cmd);


