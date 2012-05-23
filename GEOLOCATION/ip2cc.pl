#!/bin/perl

# Uses ftp://ftp.arin.net/pub/stats/ to map IPs to countries
require "/usr/local/lib/bclib.pl";

# go through each registry
for $i ("afrinic", "apnic", "arin", "lacnic", "ripencc") {
  $url = "ftp://ftp.arin.net/pub/stats/$i/delegated-$i-latest";
  ($out, $err, $res) = cache_command("curl $url","age=86400");
  debug($out);
}

