#!/bin/perl

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";
use OAuth::Lite::Consumer;

my $consumer = OAuth::Lite::Consumer->new(
    consumer_key       => $private{khanacademy}{consumerkey},
    consumer_secret    => $private{khanacademy}{consumersecret},
    site               => "https://www.khanacademy.org/api/auth2",
    request_token_path => "/request_token",
    access_token_path  => "/access_token",
    authorize_path     => "https://www.khanacademy.org/api/auth2/authorize"
);

# debug("CONSUMER:",unfold($consumer));

my $request_token = $consumer->get_request_token();

debug("RQ: $request_token");

