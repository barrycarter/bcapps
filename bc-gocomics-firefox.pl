#!/bin/perl

# brings up all gocomics strip in separate FF tabs, but slowly, so as
# not to overload Firefox/my system

require "/usr/local/lib/bclib.pl";

my($out,$err,$res) = cache_command2("curl -A 'Fauxzilla' http://www.gocomics.com/explore/comics", "age=3600");

while ($out=~s%<a href="/(.*?)">%%s) {
  # ignore entries with additional slashes or quotes
  my($url) = $1;
  if ($url=~m%[/\"]%) {next;}
  print "/root/build/firefox/firefox -remote 'openURL(http://www.gocomics.com/$url)'; sleep 5\n";
}



