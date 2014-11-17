#!/bin/perl

# Oneoff for http://webapps.stackexchange.com/questions/59072/is-it-possible-download-a-mp3-file-when-new-rss-feed-is-provided

require "/usr/local/lib/bclib.pl";

# obtain feed in question
# TODO: parametrize this

# TODO: remove age parameter when going live
my($out,$err,$res) = cache_command2("curl http://feeds.feedburner.com/Ruby5?format=xml", "age=0");

# find the mp3 link
$out=~m%(http://([^<>]*?)\.mp3)%;
my($link) = $1;

# rewrite the primary URL tag
$out=~s%<link>([^<>]*?)</link>%<link>$link</link>%sg;

# and output

print "Content-type: text/xml\n\n$out\n";
