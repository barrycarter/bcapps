#!/bin/perl

require "/usr/local/lib/bclib.pl";

my($data, $file) = cmdfile();

# debug("DATA: $data");

unless ($data=~s%<span>Ordered from</span><br/>\s*<span.*?>\s*(.*?)\s*</span>%%) {
  warn("NO MATCH REST NAME");
}

my($rest) = $1;

unless (
#	$data=~s%<span>Order Details</span><br/>\s*<span>(.*?)</span>%%
	$data=~s%<span>Order Details</span><br/>\s*<span>(.*?)</span>\s*<br/><span><b>(.*?)</b></span>%%
       ) {
  warn "NO MATCH";
} else {
  debug("GOT: $1, $2, $3");
}

die "TESTING";

unless ($data=~s%<span>Order Details</span><br/>\s*<span>(.*?)</span>\s*<span><b>(.*?)</b></span>%%s) {
  warn("NO MATCH TIME/NUM");
}

my($time, $num) = $1, $2;

debug("$rest/$time/$num");
