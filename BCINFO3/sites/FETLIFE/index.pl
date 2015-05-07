#!/bin/perl

# proxy to fetlife.com that only works if you're accessing from the
# "right" IP address (or hostname or user agent or something?)

require "/usr/local/lib/bclib.pl";

# NOTE: /usr/local/etc/fetlife.id must contain a valid fetlife session id

# TODO: cache data?

# let my ip address (remote or whatever I want to put in here) also see proxy
my($myip) = `cat /usr/local/etc/myip.txt`;
$myip=~s/\s*$//;

unless ($ENV{REMOTE_ADDR}=~/^66\.249/ || $ENV{REMOTE_ADDR} eq $myip) {
  system("cat nobot.txt");
  exit;
}

print "Content-type: text/html\n\n";

my($sessionid) = `cat /usr/local/etc/fetlife.id`;
$sessionid=~s/\s*$//;

my($url) = "https://fetlife.com$ENV{REQUEST_URI}";

# TODO: sanitize URL better!!!
$url=~s/\'//g;

my($cmd) = "curl --compress -A 'Fauxzilla' -H 'Cookie: _fl_sessionid=$sessionid' '$url'";

# print $cmd;

my($out,$err,$res) = cache_command2($cmd,"age=0");
$out=~s%s://fetlife.com%://fl20150503.94y.info%;
print $out;
