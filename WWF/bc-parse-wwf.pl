#!/bin/perl

# If you visit all of your WWF games and then click "save frame as"
# over the score of any of them, the resulting file might be parseable
# (no example included, as it may contain my sensitive data)

require "/usr/local/lib/bclib.pl";

$all = read_file("/mnt/sshfs/tmp/wwf.html");

# debug("ALL: $all");

while ($all=~s%<span class="tile letter-(.)%%s) {
  debug("1: $1");
}

