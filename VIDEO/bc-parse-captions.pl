#!/bin/perl

# fix English captions dl from youtube + maybe do other stuff

require "/usr/local/lib/bclib.pl";

my($data, $fname) = cmdfile();

my($ts, %tran);

$data=~s/<.*?>//sg;

for $i (split(/\n/, $data)) {

    if ($i=~/^\s*$/) {next;}

    if ($i=~/^(\d+):(\d{2}):(\d{2}\.?\d*)\s*\-\->\s*[\d\:\.]+/) {

 	$ts = $1*3600+$2*60+$3;
	next;
    }

    if ($i eq $prev) {next;}

    $tran{$ts} .= $i;

    $prev = $i;
}

for $i (sort {$a <=> $b} keys %tran) {
    debug("I: $i, $tran{$i}");
}

# debug(keys(%tran));


# debug($data);

