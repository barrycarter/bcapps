#!/bin/perl

require "/usr/local/lib/bclib.pl";
use IO::Socket::UNIX;

my($path) = "/home/user/20190528/socketman";

my $client = IO::Socket::UNIX->new(
        Type => SOCK_STREAM(),
        Peer => $path
    );


