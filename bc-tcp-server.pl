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

  # fork (parent ignores, child handles)

  if (fork()) {next;}

  # TODO: set ALRM to timeout to avoid hangs

  my(@data);

  while ($in = <$conn>) {
    debug("GOT: $in");
    push(@data, $in);
    # the blank line means end of headers
    if ($in=~/^\s*$/) {last;}
  }

  print $conn "Content-type: text/html\n\nThis is some content";
  
  # as the child, I must exit
  exit();

};

