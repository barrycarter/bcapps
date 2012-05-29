#!/bin/perl

# Follows the example https://developers.click2mail.com/rest-api to
# send postal mail using postedigital's API

# TODO: seriously improve this a lot

require "/usr/local/lib/bclib.pl";

# this is a staging account only
($user, $pass) = ("barrycarter", "Pr0egte9ar");

# create an address list
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

#<h>I love using $bid and $pid as variables, since there's NO WAY they
#could be confused for anything else, ha ha</h>

my($cmd4) = qq%curl -k -v -X POST https://$user:$pass\@stage.rest.click2mail.com/v1/documents/ -H "Content-Type: application/pdf" --data-binary "\@sample-data/bcpage.pdf"%;

my($out,$err,$res) = cache_command($cmd4, "age=86400");

$out=~m%<id>(.*?)</id>%;
$did = $1;

# attach document to builder
my($cmd5) = qq%curl -k -v -X PUTo https://$user:$pass\@stage.rest.click2mail.com/v1/mailingBuilders/$bid/document -H "Content-Type: application/x-www-form-urlencoded" -d "id=$did"%;

my($out,$err,$res) = cache_command($cmd5, "age=86400");

my($cmd6) = qq%curl -k -v -X PUT https://$user:$pass\@stage.rest.click2mail.com/v1/mailingBuilders/$bid/addressList -H "Content-Type: application/x-www-form-urlencoded" -d "id=$id"%;

my($out,$err,$res) = cache_command($cmd6, "age=86400");

#Is the address list ready? <h>"are we there yet?"</h>

my($cmd7) = qq%curl -k https://$user:$pass\@stage.rest.click2mail.com/v1/addressLists/$id%;

# what does it look like?

my($cmd8) = qq%curl -k -v -X GET -H "Accept: application/pdf" https://$user:$pass\@stage.rest.click2mail.com/v1/mailingBuilders/$bid/proofs/1 -o myProof.pdf%;

my($out,$err,$res) = cache_command($cmd8, "age=86400");

# and (fake) send it
my($cmd9) = qq%curl -v -X POST https://$user:$pass\@stage.rest.click2mail.com/v1/mailingBuilders/$bid/build%;

# can't cache this, it gives us a status result
my($out,$err,$res) = cache_command($cmd9, "age=0");

debug("OUT: $out, IDS: $id $bid $pid $did");

# cost me 10000-9993.98 = 6.02 fake $ to send fake letter above




