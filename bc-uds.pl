#!/bin/perl

# listen on UDS

require "/usr/local/lib/bclib.pl";

use IO::Socket::UNIX;
    my $SOCK_PATH = "$ENV{HOME}/unix-domain-socket-test.sock";
    # Server:
my $server = IO::Socket::UNIX->new(
        Type => SOCK_STREAM(),
        Local => $SOCK_PATH,
        Listen => 1,
    );
    my $count = 1;
while (my $conn = $server->accept()) {
        $conn->print("Hello " . ($count++) . "\n");
      }
