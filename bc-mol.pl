#!/bin/perl

# Follows the example https://developers.click2mail.com/rest-api to
# send postal mail using postedigital's API

require "/usr/local/lib/bclib.pl";

# this is a staging account only
($user, $pass) = ("barrycarter", "Pr0egte9ar");

$cmd1 = qq%curl -k -X POST https://$user:$pass\@stage.rest.click2mail.com/v1/addressLists -H "Content-Type: application/xml" -d "<addressList><address><name>Joe Smith</name><address1>123 Main St.</address1><city>Anytown</city><state>VA</state><postalCode>11105</postalCode></address></addressList>"%;

debug("CMD: $cmd1");

my($out,$err,$res) = cache_command($cmd1, "age=86400");

# slurp the id
$out=~m%<id>(.*?)</id>%;
$id = $1;

debug("OUT: $out, ERR: $err, ID: $id");




