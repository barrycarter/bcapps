#!/bin/perl

require "/usr/local/lib/bclib.pl";

# obtain main study page

# TODO: change age
my($out,$err,$res) = cache_command("curl http://openstudy.com/study", "age=3600");

debug($out);

die "TESTING";
# to create the comet request, we need these values
$out=~s/var lift_toWatch = \{\"(.*?)\":\s*(.*?)\s*,\s*\"(.*?)\":\s*(.*?)\s*\}//isg;
my(@ltw) = ($1, $2, $3, $4);

$out=~s/var lift_page\s*\=\s*\"(.*?)\"//isg;
my($lp) = $1;

# openstudy does this (random number) in JS
my($rand) = int(rand()*10**11);

# openstudy uses the time to the millisecond, but we can spoof the last 3
my($timems) = time().int(rand()*1000);

# the comet request url
my($comet) = "http://www.openstudy.com/comet_request/$rand/[PUTUSERCODEHERE]/$lp?$ltw[0]=$ltw[1]&$ltw[2]=$ltw[3]&_=$timems";

debug("OUT: $comet");



