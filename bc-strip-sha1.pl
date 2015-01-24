#!/bin/perl

# Strip sha1s from the output of sha1sum, return as null separated
# list, suitable for "xargs -0" (for example)

while (<>) {
  chomp;
  s/^[a-z0-9]+\s+//;
  print "$_\0";
}

