#!/bin/perl

# Given a user id and a valid fl_session_id cookie value, generate a
# list of URLs for thumbnail images for that user (which are easily
# converted to full size by changing the _120 to _720 or whatever);
# does not actually download the images, which can be done separately
# and does not require a cookie

require "/usr/local/lib/bclib.pl";

my($user,$cookie)=@_;

# obtain first picture page
my($out,$err,$res) = cache_command2("curl -H 'Cookie:  _fl_sessionid=$ARGV[1]' 'https://fetlife.com/users/$ARGV[0]/pictures?page=1'", "age=86400");

# find highest page (default 1)
my($maxpage) = 1;
while ($out=~s/page=(\d+)//) {$maxpage=max($maxpage,$1);}
debug("MAXPAGE: $maxpage");

# loop thru pages (page=1 is cached, so not redundant)

for $i (1..$maxpage) {
  # dl page, look for images, print
  ($out,$err,$res) = cache_command2("curl -H 'Cookie: _fl_sessionid=$ARGV[1]' 'https://fetlife.com/users/$ARGV[0]/pictures?page=$i'", "age=86400");
  debug("PRE: $out");
  while ($out=~s%src="(https://flpics\d+.a.ssl.fastly.net.*?)"%%s) {print "$1\n";}
}

debug("OUT: $out");

