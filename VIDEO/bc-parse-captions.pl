#!/bin/perl

# fix English captions dl from youtube + maybe do other stuff

require "/usr/local/lib/bclib.pl";

my($data, $fname) = cmdfile();

$data=~s/<.*?>//sg;

for $i (split(/\n/, $data)) {

    if ($i=~/^\s*$/) {next;}

    if ($i=~/^(\d+):(\d{2}):(\d{2}\.?\d*)\s*\-\->\s*[\d\:\.]+/) {

	# TODO: more

 	my($ts) = $1*3600+$2*60+$3;

	debug("TIMESTAMP: $ts");
	next;
    }

# 00:00:37.069

    if ($i eq $prev) {next;}

    debug("I: $i");

    $prev = $i;
}


# debug($data);

