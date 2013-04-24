#!/bin/perl

# checks if a gocomics.com comic has been updated, so I can be "first
# to comment"

require "/usr/local/lib/bclib.pl";

# list of comics (rarely changes)
my($out,$err,$res) = cache_command("curl -H 'User-Agent: Fauxilla' http://www.gocomics.com/explore/comics", "age=86400");

# trim to feature list and trim out end
$out=~s/^.*?<ul class="feature-list">//si;
$out=~s/<!-- end popular fragment cache -->.*$//isg;

# find comics
while ($out=~s%"/(.*?)"%%) {
  my($comic) = $1;
  debug("COIMIC: $comic");
}
