#!/bin/perl

# A more general version of bc-rev-search.pl

# Usage: $0 phrase file

require "/usr/local/lib/bclib.pl";

my($phrase, $file) = @ARGV;

# note that `my($rev) = reverse($phrase)` won't work because $rev is
# treated in a list context, wow!

$phrase = reverse($phrase);

debug("REV: $rev");

# TODO: at some point cache_command should use the correct
# multi-argument syntax for system

debug("COMMAND: bc-sgrep.pl $phrase $file");

my($out, $err, $res) = cache_command2("bc-sgrep.pl $phrase $file");

$out = reverse($out);

print "$out\n";

# TODO: this should be able to give multiple results when needed




