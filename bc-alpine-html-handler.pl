#!/bin/perl

# I use Alpine, an ancient mail program, and have/had its mailcap for
# value "text/html" set to '/bin/firefox --new-tab "%s"';
# unfortunately, the file %s sometimes doesn't exist which causes
# firefox errors like "Firefox can't find the file at
# /tmp/img--42364.htm"; I even tried putting a "sleep 1" in front of
# the firefox which helped, but didnt solve the problem; this script
# waits for %s to exist before opening firefox

require "/usr/local/lib/bclib.pl";

my($url) = @ARGV;

xmessage("GOT $url", 1);

# this is what I did previously, if it doesnt work, I will tweak it

my($out, $err, $res) = cache_command('/bin/firefox --new-tab file://$url');



