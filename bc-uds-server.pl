#!/bin/perl

# listen on UDS

require "/usr/local/lib/bclib.pl";
my($path) = "/home/user/20190528/socketman";

use IO::Socket::UNIX;

# Server:
my $server = IO::Socket::UNIX->new(
        Type => SOCK_STREAM(),
        Local => $path,
        Listen => 1,
    );
    my $count = 1;
while (my $conn = $server->accept()) {
        $conn->print("Hello " . ($count++) . "\n");
      }
