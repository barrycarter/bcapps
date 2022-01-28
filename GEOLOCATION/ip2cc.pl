#!/bin/perl

# Uses ftp://ftp.arin.net/pub/stats/ to map IPs to countries
require "/usr/local/lib/bclib.pl";
chdir("/home/barrycarter/BCGIT/GEOLOCATION");

open(A,">ip2cc.txt");

# TODO: below does NOT work ripencc, since server is ripe.net
# (European bastards)

# go through each registry
for $i ("afrinic", "apnic", "arin", "lacnic", "ripencc") {
  $url = "ftp://ftp.$i.net/pub/stats/$i/delegated-$i-extended-latest";
  ($out, $err, $res) = cache_command("curl -O $url","age=86400");

  # for each line
  for $j (split(/\n/,read_file("delegated-$i-extended-latest"))) {
    ($registry, $country, $type, $start, $number, $date, $x) = 
      split(/\|/, $j);

    # ignore summary (note that summary line has different fields)
    if ($date eq "summary") {next;}

    # only doing ipv4 for now (sigh)
    unless ($type eq "ipv4") {next;}

    debug("J: $j");

    # print out minimal data
    print A "$country $start $number\n";
  }
}

close(A);



