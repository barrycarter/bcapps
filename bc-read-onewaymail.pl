#!/bin/perl

# downloads no-registration-required public email address messages
# from onewaymail.com

require "/usr/local/lib/bclib.pl";
my($email) = @ARGV;
unless ($email) {die "Usage: $0 <email address>";}

# convert host to directory
%host2dir = ("mobi.web.id" => "mob", "onewaymail.com" => "owm",
	     "ag.us.to" => "agt", "gelitik.in" => "gel",
	     "fixmail.tk" => "fix");

unless ($email=~s/\@(.*?)$//) {die "BAD EMAIL: $email";}
my($host) = $1;
my($dir) = $host2dir{$host};

unless ($dir) {die "NO DIR FOR: $host";}

$url = "http://onewaymail.com/en/$dir/$email";

# one minute cache to be nice to onewaymail.com servers
($out,$err,$res) = cache_command("curl -sS $url","age=60");

while ($out=~s/href="($url.*?)"//) {
  $dl{$1}=1;
}

chdir("/usr/local/etc/onewaymail/");

open(A,"|parallel -j 10");

for $i (keys %dl) {
  $i=~m/^.*?(\d+)$/;
  if (-f $1) {next;}
  print A "curl -sSO $i\n";
}

close(A);
