#!/bin/perl

# A more general version of bc-rev-search.pl

# Usage: $0 phrase file

require "/usr/local/lib/bclib.pl";

my($phrase, $file) = @ARGV;

my($rev) = reverse($phrase);

# TODO: at some point cache_command should use the correct
# multi-argument syntax for system

my($out, $err, $res) = cache_command2("bc-sgrep.pl $rev $file");

debug("OUT: $out");


