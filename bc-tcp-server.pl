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
  my($req);

  while ($in = <$conn>) {
    debug("GOT: $in");
    push(@data, $in);
    
    # TODO: handle POST/etc requests nicely
    
    # the GET line (allows for non-HTTP/1.1 requests if they have no spaces
    # note the / is not considered part of the request
    if ($in=~m%^GET\s*/(\S+)%) {$request = $1; next;}


    # the blank line means end of headers
    if ($in=~/^\s*$/) {last;}
  }

  # process request

  my($ret) = process_request(str2hashref($request));

  # TODO: this should print as header but isnt for some reason
  print $conn "Content-type: text/plain\n\n";
  
  print $conn $ret;

  # as the child, I must exit
  exit();

};

sub process_request {

  my($hr) = @_;


  # TODO: allow other output types
  return JSON::to_json($hr);

}
