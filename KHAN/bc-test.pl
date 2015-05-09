#!/bin/perl

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";
use OAuth::Lite::Consumer;

my $consumer = OAuth::Lite::Consumer->new(
    consumer_key       => $private{khanacademy}{consumerkey},
    consumer_secret    => $private{khanacademy}{consumersecret},
    site               => "https://www.khanacademy.org",
    request_token_path => "/api/auth2/request_token",
    access_token_path  => "/api/auth2/access_token",
    authorize_path     => "https://www.khanacademy.org/api/auth2/authorize"
);

my $params = $consumer->gen_auth_params("https","https://www.khanacademy.org/api/auth2/request_token");

debug("PARAMS",unfold($params));

die "TESTING";

debug("CONSUMER:",unfold($consumer));

die "TESTING";

my $request_token = $consumer->obtain_access_token(callback_url=>"");

debug("RQ:",unfold($request_token));

