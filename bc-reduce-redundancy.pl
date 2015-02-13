#!/bin/perl

# Given a list of files, find redundant phrases in these files and
# replace them with tokenized shorter phrases. Files are expected to
# be text with no special characters (ie, all chars ASCII 32 - 126
# decimal)

# we use 128-255 only to tokenize for (more efficient if we used 0-31
# and maybe 127 too, but not now)

# we will use 4 7-byte numbers to store, so up to 3 invalid are ok

require "/usr/local/lib/bclib.pl";

# Step 1 (outside this script for now):
# cat files | sort | uniq -c | sort -nr > files.uniq

my($all) = read_file("files.uniq");

# copy I can modify
my($all2) = $all;

# we will use special characters to encode; if file already has
# special characters, note them

# below takes too long, doing it line by line but that adds complications
# while ($all2=~s/([\x7F-\xFF]+)//s) {$hash{$1} = $1;}

# the hash to hold the translations
my(%hash);
# strings to hash
my(@strs);
# special cases
my(%spec);

for $i (split(/\n/, $all)) {
  # lines CAN start with spaces, so only one space between count and line
  $i=~/\s*(\d+) (.*)$/;
  my($num,$line) = ($1,$2);

  # compute how much space we'll save (roughly) assuming token size of 3
  my($toksize) = 3;
  my($oldspace) = $num*length($line);
  # newspace = size of token times num plus one copy of orig line
  my($newspace) = $num*$toksize + length($line);

  my($savings) = $oldspace-$newspace;

  debug($i,"S: $savings");

  # temp!
  $totsavings += $savings;
  debug("SAVINGS: $totsavings");

  # no point in replacing lines that occur only once
  # TODO: should I set limit higher than 1?
  if ($num == 1) {last;}

  push(@strs, $line);
  # special characters already in string
  while ($line=~s/([\x7F-\xFF]+)//) {$spec{$1} = $1;}
}

# decide on how many 7-bit characters we will use
my($chars) = ceil(log(scalar(@strs))/log(128));

# for special characters already in string, every substring of length
# $chars must be protected

my(%prot);

for $i (keys %spec) {
  for $j (0..length($i)-$chars) {
    my($prot) = substr($i,$j,$chars);
    $prot{$prot} = 1;
  }
}

# base 128 count up from 0 to scalar(@strs), bumping for special
# characters when needed

my($count) = 0;

open(A,">brr-trans-table.txt");

for $i (@strs) {

  # the bits for $i
  my(@bits) = num2base($count,128);
  # pad with 0s so all are $chars length
  push(@bits, (0)x($chars-scalar(@bits)));
  # representation as string (we're using 128-255, so must add 128)
  my($bits) = join("",map($_=chr($_+128), @bits));

  # print the bits themselves if they are protected, else string
  print A $prot{bits}?$bits:$i,"\n";
  $count++;
}

close(A);
