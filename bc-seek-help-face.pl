#!/bin/perl

# Does what bc-seek-help.pl does, but for facebook

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# fix twitter tags to facebook format
for $i (@twitter_tags) {
  $i=~s/\#//isg;
  push(@tags, $i);
}

$phrase=join(",",@tags);

debug($phrase);

# no streaming API (or its hiding?)

# TODO: reduce age
# ($out, $err, $res) = cache_command("curl 'https://graph.facebook.com/search?q=math,perl,graphviz&locale=FB'", "age=3600");
# ($out, $err, $res) = cache_command("curl 'https://graph.facebook.com/search?q=math&q=perl&q=graphviz&locale=FB'", "age=3600");
($out, $err, $res) = cache_command("curl 'https://graph.facebook.com/search?q=math|perl|graphviz&locale=FB'", "age=3600");

print $out;



