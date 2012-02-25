#!/bin/perl

# Grabs the first few pages of
# http://www.gocomics.com/comments/page/{n} and puts them into a db
# <h>(I like dbs)</h>. Runs repeatedly in hope of keeping db complete

require "bclib.pl";

# ignoring stderr and return val
# TODO: reduce 600 below, it's too long
($page) = cache_command("curl -A 'gocomics\@barrycarter.info' http://www.gocomics.com/comments/page/1", "age=600");

while ($page=~s%<div class="comment-faux">(.*?)</div>%%s) {
  # grab comment body
  $comment = $1;

  # commentor id and name
  $comment=~s%<a href="/profile/(\d+)">(.*?)</a>%%s;
  ($id, $commentor) = ($1, $2);

  # strip commented on (and when, tho gocomics gives that in useless format)
  $comment=~s%commented on <a href="/(.*?)/(.*?)/(.*?)/(.*?)">(.*?)</a>\s*<em>(.*?)</em>%%s;
  ($strip, $yy, $mo, $da, $stripname, $time) = ($1, $2, $3, $4, $5, $6);

  # body of comment
  $comment=~s%<p><p>(.*?)</p></p>%%s;
  $body = $1;

  debug("STRIP: $strip, DATE: $yy/$mo/$da, NAME: $stripname, TIME: $time");
  debug("BODY: $body");
  debug($page);
  exit;
}
