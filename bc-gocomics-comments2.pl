#!/bin/perl

# Grabs the first few pages of
# http://www.gocomics.com/comments/page/{n} and puts them into a db
# <h>(I like dbs)</h>. Runs repeatedly in hope of keeping db complete

# --file=x: read data from file x, not from gocomics webpage

# version 2: modified for bcinfo3, denormalizes the tables (nosql is
# rubbing off on me... like a frickin cancer)

push(@INC,"/usr/local/lib");
require "bclib.pl";

# ignoring stderr and return val
# TODO: reduce 600 below, it's too long
if ($globopts{file}) {
  # this allows $page to be bzipped
  ($page) = cache_command("bzcat $globopts{file}");
} else {
  ($page) = cache_command("curl -A 'gocomics\@barrycarter.info' http://www.gocomics.com/comments/page/1", "age=60");
}

unless ($page) {die "Empty or nonexistent page";}
#debug("PAGE: $page");

while ($page=~s%<ol class='comment-thread'>(.*?)</ol>%%s) {
  # grab comment body
  $comment = $1;

  # commentor id and name
  $comment=~s%<a href="/profile/(\d+)">(.*?)</a>%%s;
  ($commentorid, $commentor) = ($1, $2);

  # strip commented on (and when, tho gocomics gives that in useless format)
  debug("COMMENT: *$comment*");
  $comment=~s%commented on <a href="/(.*?)/(\d{4})/(\d{2})/(\d{2})">(.*?)</a>\s*<em>(.*?)</em>%%s;
  debug("COMMENTED ON: $&");
  ($strip, $yy, $mo, $da, $stripname, $time) = ($1, $2, $3, $4, $5, $6);

  # some stripnames have apostrophes; stripping them is easy, but wrong
  $stripname=~s/\'//isg;

  # body of comment
  $comment=~s%<p><p>(.*?)</p></p>%%s;
  $body = $1;

  # comment id
  $comment=~s%<ul id='comment_(\d+)'>%%;
  $commentid = $1;

  $now = time();

  $query = << "MARK";
INSERT OR IGNORE INTO comments
 (commentid, commentor, commentorid, strip, stripid,
 year, month, date, body, time, unixtime) VALUES
 ($commentid, '$commentor', $commentorid, '$stripname', '$strip',
 $yy, $mo, $da, '$body', '$time', $now)
MARK
;

  push(@querys,$query);

}

open(A,">/var/tmp/gocomics-queries.txt");
print A "BEGIN;\n";
for $i (@querys) {print A "$i;\n";}
print A "COMMIT;\n";
close(A);

# testing, hoping to fix "bad characters" that seem to show up in bodies
system("sqlite3 /tmp/gocomics.db < /var/tmp/gocomics-queries.txt");

die "TESTING";

# playing it safe
system("cd /var/tmp; cp /sites/DB/gocomics.db .; sqlite3 gocomics.db < gocomics-queries.txt; mv /sites/DB/gocomics.db /sites/DB/gocomics.db.old; mv gocomics.db /sites/DB/");

# psuedo-daemonize (unless file mode)
if ($globopts{file}) {exit(0);}
sleep(150);
exec($0);

=item schema

Schema for sqlite3 db to hold these

CREATE TABLE comments (
 id INTEGER PRIMARY KEY, -- the comment id
 commentorid INT, -- id of commentor
 strip, -- short form of strip being commented on
 year INT, -- year of strip being commented on
 month INT, -- month
 date INT, -- date
 body, -- body of comment
 time, -- almost useless field
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE strips (
 stripid, -- short form of strip name
 stripname, -- long form of strip name
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX i1 ON strips(stripid,stripname);

CREATE TABLE commentors (
 commentorid INT, -- id of commentor
 name, -- name of commentor
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX i2 ON commentors(commentorid,name);

=cut

# <h>yes, I know I misspelled 'commenter' above; deal!</h>
