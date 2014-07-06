#!/bin/perl

# quick and dirty hack to count program lines (not comments/docs) in a
# given Perl script (probably not very accurate)

require "/usr/local/lib/bclib.pl";

my($file) = cmdfile();

# kill off comments, =item/=cut stuff, debugging lines, empty lines

# TODO: below incorrectly catches escaped/quoted hash marks too
$file=~s/\#.*$//mg;
$file=~s/\=item(.*?)\=cut//sg;
$file=~s/debug\(.*?\)\;//sg;
$file=~s/\n\s*\n/\n/sg;
$file = trim($file);

@file = split(/\s*\n\s*/, $file);

# some spaces are relevant, so this miscounts chars
$file=~s/\s+//sg;

debug("FILE: $file");

print scalar @file," lines\n",length($file)," characters\n";
