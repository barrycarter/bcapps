#!/bin/perl

# Grabs the first few pages of
# http://www.gocomics.com/comments/page/{n} and puts them into a db
# <h>(I like dbs)</h>. Runs repeatedly in hope of keeping db complete

push(@INC,"/usr/local/lib");
require "bclib.pl";

# ignoring stderr and return val
# TODO: reduce 600 below, it's too long
($page) = cache_command("curl -A 'gocomics\@barrycarter.info' http://www.gocomics.com/comments/page/1", "age=600");

while ($page=~s%<ol class='comment-thread'>(.*?)</ol>%%s) {
  # grab comment body
  $comment = $1;

  # commentor id and name
  $comment=~s%<a href="/profile/(\d+)">(.*?)</a>%%s;
  ($commentorid, $commentor) = ($1, $2);

  # strip commented on (and when, tho gocomics gives that in useless format)
  $comment=~s%commented on <a href="/(.*?)/(.*?)/(.*?)/(.*?)">(.*?)</a>\s*<em>(.*?)</em>%%s;
  ($strip, $yy, $mo, $da, $stripname, $time) = ($1, $2, $3, $4, $5, $6);

  # body of comment
  $comment=~s%<p><p>(.*?)</p></p>%%s;
  $body = $1;

  # comment id
  $comment=~s%<ul id='comment_(\d+)'>%%;
  $commentid = $1;

  # queries for this comment (1st/3rd query frequently redundant
  push(@querys,
"INSERT OR IGNORE INTO commentors (commentorid, name) VALUES ('$commentorid', '$commentor')",
"INSERT OR IGNORE INTO comments (id, commentorid, strip, year, month, date, body, time)
VALUES ($commentid, $commentorid, '$strip', $yy, $mo, $da, '$body', '$time')",
"INSERT OR IGNORE INTO strips (stripid, stripname) VALUES ('$strip', '$stripname')"
);
}

open(A,">/var/tmp/gocomics-queries.txt");
print A "BEGIN;\n";
for $i (@querys) {
  print A "$i;\n";
}
print A "COMMIT;\n";
close(A);

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
