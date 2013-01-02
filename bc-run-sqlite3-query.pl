#!/usr/bin/perl -0777

push(@INC,"/usr/local/lib");
require "bclib.pl";

# temp change due to DNS issues
# $sitename = "94y.info";
$sitename = "barrycarter.info";


chdir("/sites/DB/"); # where all the dbs are

# TODO: allow for just db.domain.com and list available dbs (if appropriate)

# special case for schema request
if ($ENV{HTTP_HOST}=~/(^|\.)schema\.([a-z]+)\.db\./i) {
  $db = $2;
  ($out,$err,$res) = cache_command("echo '.schema' | sqlite3 $db.db");
  if ($res) {webdie($err);}
  # changed schema to HTML solely to get word wrap
  print << "MARK"
Content-type: text/html

$out
MARK
;
exit(0);
}

# if *.[md5].[database].db.*, query is already stored in requests.db
# note: db name must be pure alpha (security measure + I can hide private dbs
# w/ numbers (not that I should put private dbs inside web root!)
if ($ENV{HTTP_HOST}=~/(^|\.)([0-9a-f]{32})\.([a-z]+)\.db\./i) {
  ($md,$db) = ($2,$3);
  $query = decode_base64(sqlite3val("SELECT query FROM requests WHERE md5='$md' AND db='$db'", "requests.db"));
  $using_hash = 1; # we are using a stored query
} else {
  # determine database
  $ENV{HTTP_HOST}=~/(^|\.)([a-z]+)\.db\./||webdie("Can't parse hostname: $ENV{HTTP_HOST}");
  $db = $2;
  # get query from POST data, strip query= + webdecode
  $query = <STDIN>;
  $query=~s/^query=//isg;
  $query=~s/\+/ /isg;
  $query=~s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
}

# test if db exists
# TODO: code getting ugly, should cleanup
unless (-f "$db.db") {
print << "MARK"
Content-type: text/html

The database <b>$db</b> doesn't exist, or I've been instructed not to give it
you, or maybe I'm just depressed and don't want to. Here I am, brain
the size of a planet...

Visit wordpress.barrycarter.info for more?

MARK
;

  exit(0);
}

# db yes, md5 sum no
if ($using_hash && !$query) {
  print << "MARK";
Content-type: text/html

Although the database $db exists, I don't have a query that
corresponds to the URL you typed. Please go to the URL below and try a
new query.<p>

<a href="http://$db.db.$sitename/">http://$db.db.$sitename/</a>

MARK
;
exit(0);
}

# TODO: chmod db to readonly UNLESS its requests.db

# these characters are permitted, but ignored
$query=~s/;//isg;
$query=~s/[\r\n]/ /isg;
$query=~s/\s+/ /isg;

# blank query? skip most steps
# TODO: goto? GOTO? goto??? really?
if ($query=~/^\s*$/) {
  print "Content-type: text/html\n\n";
  goto FORM;
}

# query safety checks
unless ($query=~/^select/i) {
  webdie("Query doesn't start w SELECT: $query");
}

# permitted characters (is this going to end up being everything?)
if ($query=~/([^a-z0-9_: \(\)\,\*\<\>\"\'\=\.\/\?\|\!\+\-\%\\])/i) {
  webdie("Query contains illegal character '$1': $query");
}

# if query not stored, store it now (we know it's "safe") + redirect
unless ($using_hash) {
  $iquery = encode_base64($query);
  $md = md5_hex($query);
  sqlite3("REPLACE INTO requests (query,db,md5) VALUES ('$iquery', '$db', '$md')", "requests.db");
  if ($SQL_ERROR) {webdie("SQL ERROR (requests): $SQL_ERROR");}
  # keep safe copy
  system("cp requests.db requests.db.saf");
  print "Location: http://$md.$db.db.$sitename/\n\n";
  exit(0);
}

# TODO: there's some code redundancy and weirdness since we ONLY run
# query if using hash; cleanup code to reflect this

# run query
$tmp = my_tmpfile("dbquery");
write_file("$query;", $tmp);
# avoid DOS by limiting cputime
($out,$err,$res) = cache_command("ulimit -t 5 && sqlite3 -html -header $db.db < $tmp");

# error?
if ($res) {
  #  webdie("SQLITE ERROR: $err, QUERY: $query");
  $out = "<tr><th>ERROR: $err</th></tr><th>QUERY: $query</th></tr>";
}

# RSS feed requested? (TODO: improve check below)
if ($ENV{REQUEST_URI}=~/rss/i) {
  open(A,"|/usr/local/bin/sqlite32rss.pl --title=$ENV{HTTP_HOST} --desc=DB_QUERY");
  print A $out;
  close(A);
  exit(0);
}

# minor tweaking
$out=~s/&lt;/</isg;
$out=~s/&gt;/>/isg;
$out=~s/&#39;/'/isg;

# helper text? (this works even if file doesn't exist)
$extra = read_file("$db.txt");

# TODO: handle errors incl timeout
# print results
print << "MARK"
Content-type: text/html

$extra

<title>$query</title>

NOTE: This page is experimental. Bug reports to
carter.barry\@gmail.com. Query language is SQLite3.

<p>QUERY: $query<p>

To edit query (or if query above is munged), see textbox at bottom of page<p>

Empty result may indicate error: I'm not sure why my error checking
code isn't working.<p>

<a href="https://github.com/barrycarter/bcapps/blob/master/bc-run-sqlite3-query.pl" target="_blank">Source code</a>

<p><table border>
$out
</table><p>
MARK
;

# and now the query form
FORM:
print << "MARK";
<form method='POST' action='http://$db.db.$sitename/'><table border>
<tr><th>Enter query below (must start w/ SELECT):</th></tr>
<tr><th><input type="submit" value="RUN QUERY"></th></tr>
<tr><th><textarea name="query" rows=20 cols=79>$query</textarea></th></tr>
<tr><th><input type="submit" value="RUN QUERY"></th></tr>
</form></table>

<p><a href='http://schema.$db.db.$sitename/' target='_blank'>Schema</a>
<a href="http://$db.db.$sitename/$db.db">Raw SQLite3 db</a>

MARK
;

# the version of warn for this script
sub warnlocal {webdie($_[0]);}

=item schema

SQLite3 schema of tables <h>(sqlite3 is "strongly untyped?")</h>

CREATE TABLE requests ( -- stored query requests
 -- the db column below is redundant but I'm ok with that
 query, -- stored query in MIME64 format
 db, -- the database for the query
 md5 -- the query hash
);

CREATE UNIQUE INDEX ui ON requests(md5);

=cut
