#!/bin/perl

# Stalks given chat rooms per http://meta.stackexchange.com/questions/218343/how-do-the-stack-exchange-websockets-work-what-are-all-the-options-you-can-send/218443#218443

require "/usr/local/lib/bclib.pl";

# http://chat.stackexchange.com/rooms/36/mathematics is test

my($rid) = 36;
my($out,$err,$res) = cache_command2("curl -L http://chat.stackexchange.com/rooms/$rid","age=3600");

unless ($out=~s%<input id="fkey" name="fkey" type="hidden" value="(.*?)" />%%s) {die "NO FKEY";}

my($fkey) = $1;

# get events

# fixed timestamp for testing
my($ts) = 1449949857-600;

# apprently, first two digits are trimmed (why?)
$ts=~s/^..//;

# testing
$ts = "49014409";

# TODO: normally, dont cache this
# TODO: can I do multiple roomids here, eg r1=foo&r2=foo.. ?
($out,$err,$res) = cache_command2("curl --trace-ascii - -d 'fkey=$fkey&r$rid=$ts' http://chat.stackexchange.com/events", "age=3600");

# debug("FK: $fkey");
debug("OUT: $out","ERR: $err");

