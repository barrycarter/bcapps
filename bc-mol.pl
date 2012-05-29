#!/bin/perl

# Follows the example https://developers.click2mail.com/rest-api to
# send postal mail using postedigital's API

# TODO: seriously improve this a lot

require "/usr/local/lib/bclib.pl";

# this is a staging account only
($user, $pass) = ("barrycarter", "Pr0egte9ar");

$cmd1 = qq%curl -k -X POST https://$user:$pass\@stage.rest.click2mail.com/v1/addressLists -H "Content-Type: application/xml" -d "<addressList><address><name>Joe Smith</name><address1>123 Main St.</address1><city>Anytown</city><state>VA</state><postalCode>11105</postalCode></address></addressList>"%;

debug("CMD: $cmd1");

my($out,$err,$res) = cache_command($cmd1, "age=86400");

# slurp the id
$out=~m%<id>(.*?)</id>%;
$id = $1;

# create a builder (does NOT require id above)
my($cmd2) = qq%curl -k -v -X POST https://$user:$pass\@stage.rest.click2mail.com/v1/mailingBuilders%;
my($out,$err,$res) = cache_command($cmd2, "age=86400");

# slurp builder id
$out=~m%<id>(.*?)</id>%;
$bid = $1;

# set item type for builder id above
# TODO: figure out what SKU I want
my($cmd3) = qq%curl -k -v -X PUT https://$user:$pass\@stage.rest.click2mail.com/v1/mailingBuilders/$bid -H "Content-Type: application/x-www-form-urlencoded" -d "sku=LT43-R"%;

my($out,$err,$res) = cache_command($cmd3, "age=86400");

# slurp presenter id (which might actually just be identical to $bid)
$out=~m%<id>(.*?)</id>%;
$pid = $1;

debug("OUT: $out, IDS: $id $bid $pid");

#<h>I love using $bid and $pid as variables, since there's NO WAY they
#could be confused for anything else, ha ha</h>





