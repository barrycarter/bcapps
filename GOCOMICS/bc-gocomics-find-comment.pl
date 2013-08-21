#!/bin/perl

# given a commentid, find what page (eg,
# http://www.gocomics.com/comments/page/120318) it is on; useful to
# complete my collection of gocomics comments

# NOTE: a given comment's page number increases as new comments come in

require "/usr/local/lib/bclib.pl";

(($commentid)=@ARGV)||die("Usage: $0 commentid");

# start looking at page 1
$page = 1;

for (;;) {
  @ids = ();
  # 3600 is a large cache time, but should be OK
  my($out,$err,$res) = cache_command("curl -A 'Fauxzilla' http://www.gocomics.com/comments/page/$page","age=3600");
  # look at ids and estimate position of $commentid
  while ($out=~s/"id":(\d+)//) {push(@ids,$1);}
  # 25/page, so... (but closer to 30 after deletes)
  $page += ($ids[0]-$commentid)/30;
  $page = int($page);
  debug("NEW PAGE: $page");
}
