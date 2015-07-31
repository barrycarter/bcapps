#!/bin/perl

# understanding pack/unpack

# $rec = pack( "l i Z32 s2", time, 72, 71, 123, 1);

# $rec = pack("B8",'01101111');

$rec = unpack("S2", "\0\1");
print "<rec>$rec</rec>\n";
