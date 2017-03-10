#!/bin/perl

use Net::Jabber::Server;
use Net::Jabber qw(Server);
# use Net::Jabber::Debug;
# use XML::Stream;

require "/usr/local/lib/bclib.pl";

# $foo = new XML::Stream;
# $foo->SetCallBacks();
# debug(var_dump("STREAM",$foo));

$Server = new Net::Jabber::Server();
$Server->Start();

die "TESTING";

$Server->{STREAM}->SetCallBacks();
debug(var_dump("SERVER",$Server));
debug(var_dump("SERVER",$Server->{STREAM}));
$Server->Start();

die "TESTING";



$Server->Start(jabberxml=>"custom_jabber.xml",
                hostname=>"foobar.net");

%status = $Server->Process();
%status = $Server->Process(5);
$Server->Stop();

