#!/bin/perl


# lists for and serves tile requests; currently just a "file" server
# but may do fanicer things later

require "/usr/local/lib/bclib.pl";
use Socket;
use HTTP::Server::Brick;

# TODO: decide on port/etc

# TODO: make secure

my($port) = 22779;

# this is magic that makes sockets work (I dont really understand it)
socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));
bind(S,sockaddr_in($port,INADDR_ANY));
listen(S,SOMAXCONN);

# accept socket connections eternally

for (;;) {

  # this IS blocking so not inefficient
  accept(C,S);

  # once we get one, read what they send us
  

  debug("Got one!");
}




