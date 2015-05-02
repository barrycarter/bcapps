#!/bin/perl

# proxy to fetlife.com that only works if you're accessing from the
# "right" IP address (or hostname or user agent or something?)

# NOTE: /usr/local/etc/fetlife.id must contain a valid fetlife session id

print "Content-type: text/html\n\n";

my($sessionid) = `cat /usr/local/etc/fetlife.id`;
$sessionid=~s/\s*$//;

# for $i (sort keys %ENV) {print "$i -> $ENV{$i}\n";}

# special cases
if ($ENV{REQUEST_URI} eq "/" || $ENV{REQUEST_URI} eq "/home/") {
  $ENV{REQUEST_URI} = "/home/v4/";
}

my($url) = "https://fetlife.com$ENV{REQUEST_URI}";

# TODO: sanitize URL better!!!
$url=~s/\'//g;

# print "curl --compress -A 'Fauxzilla' -H 'Cookie: _fl_sessionid=$sessionid' '$url'";

system("curl --compress -A 'Fauxzilla' -H 'Cookie: _fl_sessionid=$sessionid' '$url'");

