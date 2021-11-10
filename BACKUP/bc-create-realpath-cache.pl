#!/bin/perl

# because realpath takes so long to run (well, at least on 90M files),
# create a cache that is hopefully faster

# input: a list of null separated filenames on the STDIN (this program expects to run from xargs -0)

# output: same filenames followed by null and their current path on
# the disk (if no path on disk, "realpath" is considered to be the
# filename itself)

require "/usr/local/lib/bclib.pl";

my($all) = join("\0", @ARGV);

# debug("ALL: $all");

debug("CALLED WITH $#ARGV+1 args");

# TODO: better tempfile naming

open(A, "|xargs -0 realpath 2>&1 &> /tmp/bcrc.txt");

print A $all;

close(A);

my(@targets) = `/bin/cat /tmp/bcrc.txt`;


for $i (0..$#targets) {

  # don't print on error, new backup program automatically assumes
  # missing = original path

  if ($targets[$i]=~/^realpath: /) {next;}

  chomp($targets[$i]);

#  debug("*$ARGV[$i]*, *$targets[$i]*");

  unless ($ARGV[$i] eq $targets[$i]) {
    print "$ARGV[$i]\t$targets[$i]\n";
  }
}

# TODO: add checks that files are equal length, handle special cases, etc
