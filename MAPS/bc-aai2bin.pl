#!/bin/perl

require "/usr/local/lib/bclib.pl";

while (<>) {

    # ignore lines that start with a letter
    if (/^[a-z]/i) {next;}

    my(@cols) = split(/\s+/, $_);

    for $j (@cols) {
	print pack("d", $j);
    }

#    debug("COLS: $#cols+1");
}

