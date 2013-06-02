#!/usr/bin/perl -0777

# run an arbitrary readonly SQL query webapp
# v2 does NOT canonize the domain name, tries to derive it from HTTP_HOST
# format: [query|"schema"].db.(db|database).other.stuff

require "/usr/local/lib/bclib.pl";

# where the dbs are <h>(sadly, /sites/GIRLS/ does not work as well...)</h>
# this is a really ugly hack so I can run on my home machine
@dirpath = ("/home/barrycarter/LOCALHOST/20121228/DB", "/sites/DB");

for $i (@dirpath) {
  if (-d $i) {chdir($i); last;}
}

# parse hostname (tld includes the ".db" part
# TODO: allow for just db.domain.com and list available dbs (if appropriate)
if ($ENV{HTTP_HOST}=~/^([^\.]+)\.([^\.]+)\.(db|database)\.(.*?)$/i) {
  # query or schema request
  ($queryhash, $db, $tld) = ($1, $2, "$3.$4");
} elsif ($ENV{HTTP_HOST}=~/^([^\.]+)\.(db|database)\.(.*?)$/i) {
  # just tablename, no schema/query
  ($queryhash, $db, $tld) = ("", $1, "$2.$3");
}

debug("VALS: $queryhash/$db/$tld");

# special case for schema request
if ($queryhash=~/^schema$/i) {
  print "Content-type: text/plain\n\n";
  ($out,$err,$res) = cache_command2("echo '.schema' | sqlite3 $db.db");
  if ($res) {webdie("SCHEMA ERROR: $err");}
  print $out;
  exit(0);
}

# if query is md5 hash, query already in db
if ($queryhash) {
  $query = decode_base64(sqlite3val("SELECT query FROM requests WHERE md5='$queryhash' AND db='$db'", "requests.db"));
} else {
  # get query from POST data, strip query= + webdecode
  $query = <STDIN>;
  $query=~s/^query=//isg;
  $query=~s/\+/ /isg;
  $query=~s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
}

# TODO: cant preprint text/html since Location: directive later requires I NOT do that

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

# db yes, hash no
if ($queryhash && !$query) {
  print << "MARK";
Content-type: text/html

Although the database $db exists, I dont have a query that
corresponds to the URL you typed. Please go to the URL below and try a
new query.<p>

<a href="http://$db.$tld/">http://$db.$tld/</a>

MARK
;
exit(0);
}

# TODO: chmod db to readonly UNLESS its requests.db

# these characters are permitted, but ignored
$query=~s/[\;\r\n]/ /isg;
# trim spaces to canonize query (may not be a great idea)
$query=~s/\s+/ /isg;

# blank query? skip most steps
# TODO: goto? GOTO? goto??? really?
if ($query=~/^\s*$/) {goto FORM;}

# query safety checks
unless ($query=~/^select/i) {webdie("Query doesn't start w SELECT: $query");}
# permitted characters (is this going to end up being everything?)
if ($query=~/([^a-z0-9_: \(\)\,\*\<\>\"\'\=\.\/\?\|\!\+\-\%\\])/i) {
  webdie("Query contains illegal character '$1': $query");
}

# if query not stored, store it now (we know it's "safe") + redirect
unless ($queryhash) {
  $iquery = encode_base64($query);
  $queryhash = md5_hex($iquery);
  sqlite3("REPLACE INTO requests (query,db,md5) VALUES ('$iquery', '$db', '$queryhash')", "requests.db");
  if ($SQL_ERROR) {webdie("SQL ERROR (requests): $SQL_ERROR");}
  # keep safe copy
  #  system("cp requests.db requests.db.saf");
  print "Location: http://$queryhash.$db.$tld/\n\n";
  exit(0);
}

# now ok to print text/html
print "Content-type: text/html\n\n";

# TODO: there's some code redundancy and weirdness since we ONLY run
# query if using hash; cleanup code to reflect this

# run query
$tmp = my_tmpfile("dbquery");
write_file("$query;", $tmp);
# avoid DOS by limiting cputime
($out,$err,$res) = cache_command2("ulimit -t 5 && sqlite3 -html -header $db.db < $tmp");

# error?
if ($res) {
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
# TODO: improe this, it breaks stuff
$out=~s/&lt;/</isg;
$out=~s/&gt;/>/isg;
$out=~s/&#39;/'/isg;

# helper text? (this works even if file doesn't exist)
$extra = read_file("$db.txt");

# TODO: handle errors incl timeout
# print results
print << "MARK"
$extra

<title>$query</title>

NOTE: This page is experimental. Bug reports to
carter.barry\@gmail.com. Query language is SQLite3.

<p><pre>QUERY: $query</pre><p>

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
<form method='POST' action='http://$db.$tld/'><table border>
<tr><th>Enter query below (must start w/ SELECT):</th></tr>
<tr><th><input type="submit" value="RUN QUERY"></th></tr>
<tr><th><textarea name="query" rows=20 cols=79>$query</textarea></th></tr>
<tr><th><input type="submit" value="RUN QUERY"></th></tr>
</form></table>

<p><a href='http://schema.$db.$tld/' target='_blank'>Schema</a>
<a href="http://$db.$tld/$db.db">Raw SQLite3 db</a>

MARK
;

=item schema

SQLite3 schema of tables <h>(sqlite3 is "strongly untyped?")</h>

CREATE TABLE requests ( -- stored query requests
 -- the db column below is redundant but Im ok with that
 query, -- stored query in MIME64 format
 db, -- the database for the query
 md5 -- the query hash
);

CREATE UNIQUE INDEX ui ON requests(md5);

=cut
