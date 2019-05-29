#!/bin/perl

# listen on UDS

require "/usr/local/lib/bclib.pl";
use IO::Socket::UNIX;

my($path) = "/home/user/20190528/socketman";

my($buf);

# ignore children completion

$SIG{CHLD} = 'IGNORE';

open(A, "/home/user/test.owl");

my $server = IO::Socket::UNIX->new(
   Type => SOCK_STREAM(), Local => $path, Listen => 1);

while (my $conn = $server->accept()) {

  # fork

  if (fork()) {
    debug("I am the parent, I will just wait for the next connection");
    next;
  }

  debug("I am the child, I will handle this request");

  sysseek(A, 123, SEEK_SET);
  sysread(A, $buf, 100);

  my $in = <$conn>;
  print $conn "You said: $in, have some $buf\n";

  # as the child, I must exit
  exit();

};

