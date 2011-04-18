#!/bin/perl

# Script where I test code snippets; anything that works eventually
# makes it into a library or real program

# chunks are normally separated with 'die "TESTING";'

require "bclib.pl";

# RPC-XML

# using raw below so i can cache and stuff

$req=<<"MARK";
<?xml version="1.0"?><methodCall>
<methodName>system.listMethods</methodName>
</methodCall>
MARK
;

write_file($req,"/tmp/rpc1.txt");

system("curl -o /tmp/rpc2.txt --data-binary \@/tmp/rpc1.txt http://wordpress.barrycarter.info/xmlrpc.php");

die "TESTING";

use RPC::XML;
use RPC::XML::Parser;
require RPC::XML::Client;

$cli = RPC::XML::Client->new('http://wordpress.barrycarter.info/xmlrpc.php');
$resp = $cli->send_request('system.listMethods');

debug(@{$resp->value});

die "TESTING";


$req = RPC::XML::request->new('fetch_prime_factors', 
 RPC::XML::int->new(985120528));

debug($req);

$resp = RPC::XML::Parser->new()->parse(STREAM);

debug($resp);

die "TESTING";

# reading Mathematica interpolation files

$all = read_file("sample-data/manytables.txt");

while ($all=~s/InterpolatingFunction\[(.*?)\]//s) {
  $func = $1;

  # get rid of pointless domain
  # {} are not special to Perl?!
  $func=~s/{{(.*?)}}//;

  # xvals
  $func=~s/{{(.*?)}}//s;
  $xvals = $1;
  debug("XV: $xvals");

  # split and fix
  @xvals=split(/\,|\n/s, $xvals);

  for $i (@xvals) {
    $i=~s/(.*?)\*\^(\d+)/$1*10**$2/iseg;
  }

  debug($func);

}

