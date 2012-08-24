#!/bin/perl

# quick and dirty script to grab and cache the 'date' pages on wikipedia

require "/usr/local/lib/bclib.pl";
dodie('chdir("/home/barrycarter/BCGIT/TIMELINE")');

for $i (1..12) {
  for $j (1..31) {
    # note: this picks up impossible dates like June 31st, but I'm OK w that

    $page = urlencode("$months[$i] $j");
    $outfile = "$months[$i]$j";
    debug($outfile);
    if (-f $outfile) {next;}

    # in theory, could use parallel, but only 366 of them
    ($out, $res, $err) = cache_command("curl -o $outfile 'http://en.wikipedia.org/w/api.php?format=xml&action=query&titles=$page&prop=revisions&rvprop=content'");
  }
}

