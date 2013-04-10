#!/bin/perl

# echos back an HTTP request (with remote IP and port for reference)
# called from inetd.conf

use Socket;

print "HTTP/1.1 200 OK\n";
print "Content-type: text/plain\n\n";

while (<STDIN>) {
  print $_;
  if (/^\s*$/) {last;}
}

my $hersockaddr    = getpeername(STDOUT);
my ($port, $iaddr) = sockaddr_in($hersockaddr);
my $ip = inet_ntoa($iaddr);

print "IP ADDRESS: $ip\nPORT: $port\n";


