#!/usr/bin/perl

# lets me connect to twitter as myself, not a general app

use Net::Twitter;

require "/home/barrycarter/bc-private.pl";
require "/usr/local/lib/bclib.pl";

my $nt = Net::Twitter->new(
 ssl => 1, legacy_lists_api => 0, traits => [qw/API::RESTv1_1/],
 consumer_key => $private{twitter}{consumer_key},
 consumer_secret => $private{twitter}{consumer_secret},
 access_token => $private{twitter}{token},
 access_token_secret => $private{twitter}{token_secret}
);

debug(var_dump("friends", $nt->friends()));


