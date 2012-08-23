#!/bin/perl

# Does what bc-seek-help.pl does, but for facebook

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# fix twitter tags to facebook format
for $i (@twitter_tags) {$i=~s/\#//isg;}

# no streaming API (or its hiding?)

for $i (@twitter_tags) {
  ($out, $err, $res) = cache_command("curl 'https://graph.facebook.com/search?q=$i&locale=FB'", "age=3600&cachefile=/tmp/face-$i");
  debug($out);
}







