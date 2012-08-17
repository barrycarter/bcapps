#!/bin/perl
use Digest::SHA;

%twitter_auth_hash = (
"oauth_access_token" => "47849378-rZlzmwutYqGypbLsQUoZUsGdDkVVRkjkOkSfikNZC",
"oauth_access_token_secret" => "YePiEkSDFdYAOgscijMCazcSfBflykjsEyaaVbuJeO",
"consumer_key" => "UEIUyoBjBRomdvrVcUTn",
"consumer_secret" => "rUOeZMYraAapKmXqYpxNLTOuGNmAQbGFqUEpPRlW"
);

# if uncommented, pull my actual data
# require "bc-private.pl";

$twitter_auth_hash{"oauth_signature_method"} = "HMAC-SHA1";
$twitter_auth_hash{"oauth_version"} = "1.0";
$twitter_auth_hash{"oauth_timestamp"} = time();
$twitter_auth_hash{"oauth_nonce"} = time();

for $i (keys %twitter_auth_hash) {
  push(@str,"$i=".urlencode($twitter_auth_hash{$i}));
}

$str = join("&",@str);

# thing to sign
$url = "GET $str";

# signing it
$sig = urlencode(Digest::SHA::hmac_sha256_base64($url, "rUOeZMYraAapKmXqYpxNLTOuGNmAQbGFqUEpPRlW&YePiEkSDFdYAOgscijMCazcSfBflykjsEyaaVbuJeO"));

# full URL incl sig
$furl = "https://api.twitter.com/oauth/request_token?$str&oauth_signature=$sig";

# system("curl -o /tmp/testing.txt '$furl'");


print "FURL: $furl\n";
print "STR: $str\n";
print "SIG: $sig\n";

sub urlencode {
  my($str) = @_;
  $str=~s/([^a-zA-Z0-9])/"%".unpack("H2",$1)/iseg;
  $str=~s/ /\+/isg;
  return $str;
}

