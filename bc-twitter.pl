#!/bin/perl

# attempt to create a twitter library or app or something ... maybe

require "bclib.pl";
use Digest::HMAC_SHA1;

# kludge below
@keys = split("\n",read_file("/home/barrycarter/bc-twitter-keys.txt"));
map(s/^.*?=//isg, @keys);
map(s/[\";\s]//isg, @keys);
($apikey, $pubkey, $seckey) = @keys;

# timestamp and nonce for request
$timestamp = time();
$nonce = "bctwitter$timestamp";

# the request hash
%req = (
	"oauth_consumer_key" => $pubkey,
	"oauth_signature_method" => "HMAC-SHA1",
	"oauth_timestamp" => $timestamp,
	"oauth_nonce" => $nonce
);

# lexigraphical order
# <h>I knew there was a reason I obsessively sort hash keys</h>
for $i (sort keys %req) {
  push(@str, "$i=$req{$i}");
}

# the request
$req = join("&", @str);

# the thing to sign
$sigme = "GET&api.twitter.com&".urlencode($req);

# signing the request
my($hmac) = Digest::HMAC_SHA1->new($seckey);
$hmac->add($sigme);
$sig = urlencode($hmac->b64digest);

# and sending the whole thing
$url = "https://api.twitter.com/oauth/request_token?$req&ouath_signature=$sig";

debug($url);

# and get the token
$token = cache_command("curl '$url'");

debug(read_file($token));
