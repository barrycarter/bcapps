#!/bin/perl

# scrapes addresses from http://www.baiterbase.co.uk/emailrss.php
# (this appears to be the least verbose one); can use these addresses
# to ping potential scammers (but not everyone on this list is
# necessarily a scammer)

require "/usr/local/lib/bclib.pl";

my($out,$err,$res) = cache_command("curl http://www.baiterbase.co.uk/emailrss.php","age=3600");

# only todays
# this is broken HTML (XML) [maybe not], but hey... they do good work
$out=~s%</title><description>(.*?)</description>%%is;
$body = $1;

# split into addrs, sort/uniq
@addr = split(/\,|\n|\s+/s, $body);

# get rid of things like "goodnessmajzoub@yahoo.com>goodnessmajzoub@yahoo.com"
for $i (@addr) {
  $i=~s/^.*?>//isg;
  $hash{$i} = 1;
}

for $i (sort keys %hash) {
  print "$i\n";
}




