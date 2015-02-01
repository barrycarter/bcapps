#!/bin/perl

# Fun w/ Huffman encoding

require "/usr/local/lib/bclib.pl";

# split file into chunks of 4 bytes per line, sort lines, convert \n to space

my($all,$fname) = cmdfile();
$all=~s/\n/ /g;
debug("ALL: $all");

while ($all=~s/^(....)//) {print "$1\n";}

