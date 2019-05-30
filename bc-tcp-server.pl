#!/bin/perl

# listen on UDS

require "/usr/local/lib/bclib.pl";
use IO::Socket::UNIX;

my($buf);

# ignore children completion

$SIG{CHLD} = 'IGNORE';

open(A, "/home/user/test.owl");

my $server = IO::Socket::INET->new(
   LocalAddr => "127.0.0.1", LocalPort => "22779",
   Proto => "tcp", Listen => 20)||die("Can't create socket, $!");

debug("SERVER: $server");

while (my $conn = $server->accept()) {

  # fork

  if (fork()) {
    debug("I am the parent, I will just wait for the next connection");
    next;
  }

  debug("I am the child, I will handle this request");

  sysseek(A, 123, SEEK_SET);
  sysread(A, $buf, 100);

  while ($in = <$conn>) {
    print $conn "You said: $in, have some $buf\n";
  }

  # as the child, I must exit
  exit();

};

