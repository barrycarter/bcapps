#!/bin/perl

require "/usr/local/lib/bclib.pl";

# obtain main study page

# TODO: change age
my($out,$err,$res) = cache_command("curl http://openstudy.com/study", "age=3600");

# to create the comet request, we need these values
$out=~s/var lift_toWatch = \{\"(.*?)\":\s*(.*?)\s*,\s*\"(.*?)\":\s*(.*?)\s*\}//isg;
my(@ltw) = ($1, $2, $3, $4);

# the comet request url
my($comet) = "http://www.openstudy.com/comet_request/[PUTRANDHERE]/[PUTUSERCODEHERE]/[lift_page]?$ltw[0]=$ltw[1]&$ltw[2]=$ltw[3]&_=[TIMETOMILLSECOND]"

debug("TEST: $1, $2, $3, $4");

debug("OUT: $out");

