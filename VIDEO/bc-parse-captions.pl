#!/bin/perl

# fix English captions dl from youtube + maybe do other stuff

require "/usr/local/lib/bclib.pl";

my($data, $fname) = cmdfile();

$data=~s/<.*?>//sg;

for $i (split(/\n/, $data)) {

    if ($i=~/^\s*$/) {next;}

    if ($i=~/^[\d\:\.]+\s*\-\->\s*[\d\:\.]+/) {
	# TODO: more
	debug("TIMESTAMP: $i");
	next;
    }

    if ($i eq $prev) {next;}

    debug("I: $i");

    $prev = $i;
}


# debug($data);

