#!/bin/perl

# Grabs the first few pages of
# http://www.gocomics.com/comments/page/{n} and puts them into a db
# <h>(I like dbs)</h>. Runs repeatedly in hope of keeping db complete

# --file=x: read data from file x, not from gocomics webpage
# --printonly: print queries, do not execute them

# --db=x: use a database other than gocomics.db (really only useful
# for local testing)

# version 2: modified for bcinfo3, denormalizes the tables (nosql is
# rubbing off on me... like a frickin cancer)

require "/usr/local/lib/bclib.pl";

defaults("db=gocomics");

# ignoring stderr and return val
# TODO: reduce 600 below, it's too long
if ($globopts{file}) {
  # this allows $page to be bzipped
  ($page) = cache_command2("bzcat -f $globopts{file}");
} else {
  ($page) = cache_command2("curl -H 'Accept: text/html' -A 'gocomics\@barrycarter.info' http://www.gocomics.com/comments/page/1", "age=60");
}

unless ($page) {warn "Empty or nonexistent page"; exit(0);}

# this appears to be better way to get comments
@comments = split(/<ol class='comment-thread'>/,$page);
# first "comment" is just garbage to start of comments
shift(@comments);

for $comment (@comments) {

  # commentor id and name
  $comment=~s%<a href="/profile/(\d+)">(.*?)</a>%%s;
  ($commentorid, $commentor) = ($1, $2);

  # strip commented on (and when, tho gocomics gives that in useless format)
  $comment=~s%commented on <a href="/(.*?)/(\d{4})/(\d{2})/(\d{2})">(.*?)</a>\s*<em>(.*?)</em>%%s;
  ($strip, $yy, $mo, $da, $stripname, $time) = ($1, $2, $3, $4, $5, $6);

  # body of comment
  $comment=~s%<p><p>(.*?)</p></p>%%s;
  $body = $1;

  # comment id
  $comment=~s%<ul id='comment_(\d+)'>%%;
  $commentid = $1;

  # cleanup apostrophes and backslashes
  # TODO: still confused about why this changes loop vars and not just $i
  for $i ($stripname, $commentor, $body) {
    $i=~s/\'/&\#39;/isg;
    $i=~s/\\/&\#92;/isg;
  }

  $now = time();

  # useful for joining
  $url = "http://gocomics.com/$strip/$yy/$mo/$da";

  $query = << "MARK";
REPLACE INTO comments
 (commentid, commentor, commentorid, strip, stripid,
 year, month, date, body, time, unixtime, url) VALUES
 ($commentid, '$commentor', $commentorid, '$stripname', '$strip',
 $yy, $mo, $da, '$body', '$time', $now, '$url')
MARK
;

  push(@querys,$query);

}

if ($globopts{printonly}) {
  print "BEGIN;\n";
  for $i (@querys) {print "$i;\n";}
  print "COMMIT;\n";
  exit(0);
}

open(A,">/var/tmp/gocomics-queries.txt");
print A "BEGIN;\n";
for $i (@querys) {print A "$i;\n";}
print A "COMMIT;\n";
close(A);

# testing, hoping to fix "bad characters" that seem to show up in bodies
# system("sqlite3 /tmp/gocomics.db < /var/tmp/gocomics-queries.txt");
# die "TESTING";

# playing it safe
system("cd /var/tmp; cp /sites/DB/$globopts{db}.db .; sqlite3 $globopts{db}.db < gocomics-queries.txt; mv /sites/DB/$globopts{db}.db /sites/DB/$globopts{db}.db.old; mv $globopts{db}.db /sites/DB/");

# psuedo-daemonize (unless file mode)
if ($globopts{file}) {exit(0);}
sleep(150);
exec($0);
