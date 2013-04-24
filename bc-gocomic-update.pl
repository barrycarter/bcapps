#!/bin/perl

# checks if a gocomics.com comic has been updated, so I can be "first
# to comment"

require "/usr/local/lib/bclib.pl";

# tomorrow
# TODO: This may not not 100% accurate
$tom = time()+86400;

# URL format
$urlf = strftime("%Y/%m/%d", localtime($tom));
# printed format
$urlp = strftime("%B %d, %Y", localtime($tom));

# list of comics (rarely changes)
my($out,$err,$res) = cache_command("curl -H 'User-Agent: Fauxilla' http://www.gocomics.com/explore/comics", "age=86400");

# trim to feature list and trim out end
$out=~s/^.*?<ul class="feature-list">//si;
$out=~s/<!-- end popular fragment cache -->.*$//isg;

# find comics
while ($out=~s%"/(.*?)"%%) {
  my($comic) = $1;

  my($out,$err,$res) = cache_command("curl -L -H 'User-Agent: Fauxilla' http://www.gocomics.com/l$comic/$urlf","age=600");

  # does it have "tomorrows" true date?
  if ($out=~/$urlp/) {
    print "UPDATED($comic): $urlp\n";
  }
}
