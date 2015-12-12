#!/bin/perl

# Stalks given chat rooms per http://meta.stackexchange.com/questions/218343/how-do-the-stack-exchange-websockets-work-what-are-all-the-options-you-can-send/218443#218443

require "/usr/local/lib/bclib.pl";

# http://chat.stackexchange.com/rooms/36/mathematics is test

my($rid) = 240;
my($out,$err,$res) = cache_command2("curl -L http://chat.stackexchange.com/rooms/$rid","age=3600");

unless ($out=~s%<input id="fkey" name="fkey" type="hidden" value="(.*?)" />%%s) {die "NO FKEY";}

my($fkey) = $1;

# get events

# fixed timestamp for testing
my($ts) = 1449949857-600;

# TODO: don't hardcode 'mathematics' below
$headers = "-H 'User-Agent: Mozilla/5.0  (X11; Linux i686; rv:14.0) Gecko/20100101 Firefox/14.0.1' -H 'X-Requested-With: XMLHttpRequest' -H 'Referer: http://chat.stackexchange.com/rooms/$rid/' -H 'Cookie: x=0' -H 'Connection: keep-alive' -H 'Pragma: no-cache'";

# TODO: normally, dont cache this
# TODO: can I do multiple roomids here, eg r1=foo&r2=foo.. ?
($out,$err,$res) = cache_command2("curl --trace-ascii - $headers -d 'fkey=$fkey&r$rid=$ts' http://chat.stackexchange.com/events", "age=3600");

# debug("FK: $fkey");
debug("OUT: $out","ERR: $err");

