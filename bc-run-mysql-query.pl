#!/usr/bin/perl -0777

# run an arbitrary readonly MySQL query webapp
# starts off as a copy bc-run-sqlite3-query.pl
# format: [rss|csv|].[query|"schema"].db.(db|database).other.stuff

require "/usr/local/lib/bclib.pl";

# TODO: this is going to get ugly, but confirms I am running the right prog
$globopts{debug} = 1;
print "Content-type: text/html\n\n";
webug("THIS IS MYSQL");

# TODO: sense I'm not handling the printing of content-type: text/html
# optimally

# where the dbs are <h>(sadly, /sites/GIRLS/ does not work as well...)</h>
# this is a really ugly hack so I can run on my home machine
@dirpath = ("/home/barrycarter/LOCALHOST/20121228/DB", "/sites/DB");
for $i (@dirpath) {if (-d $i) {chdir($i); last;}}

# check to see if db exists
# TODO: add non-redundant error checking
# parse hostname ($tld includes ".db." part)
if ($ENV{HTTP_HOST}=~/^schema\.([a-z]+)\.(db|database)\.(.*?)$/i) {
  # schema request($database, $tld)
  check_db($1);
  schema_request($1,"$2.$3");
} elsif ($ENV{HTTP_HOST}=~/^rss\.([0-9a-f]+)\.([a-z]+)\.(db|database)\.(.*?)$/i) {
  # request for RSS (same subroutine as request for query)
  check_db($2);
  query_request($1,$2,"$3.$4", "rss");
} elsif ($ENV{HTTP_HOST}=~/^csv\.([0-9a-f]+)\.([a-z]+)\.(db|database)\.(.*?)$/i) {
  # request for CSV (same subroutine as request for query)
  check_db($2);
  query_request($1,$2,"$3.$4", "csv");
} elsif ($ENV{HTTP_HOST}=~/^([0-9a-f]+)\.([a-z]+)\.(db|database)\.(.*?)$/i) {
  # request for existing query
  check_db($2);
  query_request($1,$2,"$3.$4");
} elsif ($ENV{HTTP_HOST}=~/^post\.([a-z]+)\.(db|database)\.(.*?)$/i) {
  # posting a new query
  check_db($1);
  post_request($1,"$2.$3");
} elsif ($ENV{HTTP_HOST}=~/^([a-z]+)\.(db|database)\.(.*?)$/i) {
  # request for form only
  check_db($1);
  print "Content-type: text/html\n\n";
  # lets me confirm at least the CGI is right
  form_request($1,"$2.$3");
} elsif ($ENV{HTTP_HOST}=~/^(db|database)\.(.*?)$/i) {
  # request for list of dbs (currently not honored)
  dblist_request("$1.$2");
} else {
  print "Content-type: text/html\n\nHostname $ENV{HTTP_HOST} not understood";
}

exit();

sub check_db {
  my($db) = @_;
  # TODO: not this
  return 1;
  # doesnt exist
  unless (-f "$db.db") {
    print "Content-type: text/html\n\n";
    webdie("$db.db: no such file");
  }
}

# this subroutines are specific to this program thus not well documented
sub schema_request {
  my($db,$tld) = @_;
  print "Content-type: text/plain\n\n";
  my($out,$err,$res) = cache_command2("echo '.schema' | sqlite3 $db.db");
  if ($res) {webdie("SCHEMA ERROR: $err");}
  print $out;
}

# request for query already in requests.db
sub query_request {
  my($hash,$db,$tld,$rss) = @_;
  my($query) = decode_base64(sqlite3val("SELECT query FROM requests WHERE md5='$hash' AND db='$db'", "requests.db"));

  # no query returned?
  unless ($query) {
    webdie("$db exists, but no query with hash $hash. Try http://$db.$tld/");
  }

  # actually run query (use tmpfile to avoid command line danger)
  my($tmp) = my_tmpfile("dbquery");
  write_file("$query;", $tmp);

  # if $rss is actually "csv", give comma-separated output
  my($format);
  if ($rss=~/^csv$/) {$format="csv";} else {$format="html";}

  # avoid DOS by limiting cputime
  my($out,$err,$res) = cache_command2("ulimit -t 5 && sqlite3 -$format -header $db.db < $tmp");

  # restore hyperlinks and quotes
  $out=~s/&lt;/</isg;
  $out=~s/&gt;/>/isg;
  $out=~s/&quot;/\"/isg;
  $out=~s/&\#39;/\'/isg;

  # error?
  if ($res) {
    print "Content-type: text/html\n\n";
    webdie("QUERY: $query<br>ERROR: $err<br>");
  }

  # known good result; requesting rss?
  if ($rss=~/^rss$/i) {
    local(*A);
    open(A,"|/usr/local/bin/sqlite32rss.pl --title=$ENV{HTTP_HOST} --desc=DB_QUERY");
    print A $out;
    close(A);
  } else {
    # info about db
    if ($format=~/^csv$/) {
      print "Content-type: text/plain\n\n";
    } else {
      print "Content-type: text/html\n\n";
    }
    print read_file("$db.txt");
    print << "MARK";
<title>$query</title>

NOTE: This page is experimental. Bug reports to
carter.barry\@gmail.com. Query language is SQLite3.<p>

Prepend rss. to the URL for an RSS feed, csv. to the URL for CSV output.<p>

<p><pre>QUERY: $query</pre><p>

To edit query (or if query above is munged), see textbox at bottom of page<p>

Empty result may indicate error: I'm not sure why my error checking
code isn't working.<p>

<a href="https://github.com/barrycarter/bcapps/blob/master/bc-run-sqlite3-query2.pl" target="_blank">Source code</a>

<p><table border>
$out
</table><p>
MARK
;
    form_request($db,$tld,$query,$hash);
  }
}

sub post_request {
  my($db,$tld) = @_;
  my($query) = <STDIN>;

  # check this query, add it to requests.db as MIME, redirect to execute it
  $query=~s/^query=//isg;
  $query=~s/\+/ /isg;
  $query=~s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
  # these characters are permitted, but ignored
  $query=~s/[\;\r\n]/ /isg;
  # trim spaces to canonize query (may not be a great idea)
  $query=~s/\s+/ /isg;

  # if blank query, just redirect to main site
  unless ($query) {
    print "Location: http://$db.$tld/\n\n";
    return;
  }

  # safety checks
  unless ($query=~/^select/i) {webdie("Query doesn't start w SELECT: $query");}
  # permitted characters (is this going to end up being everything?)
  if ($query=~/([^a-z0-9_: \(\)\,\*\<\>\"\'\=\.\/\?\|\!\+\-\%\\])/i) {
    webdie("Query contains illegal character '$1': $query");
  }

  # query is now safe, add to requests.db (as base 64)
  my($iquery) = encode_base64($query);
  my($queryhash) = md5_hex($iquery);
  debug("TESTING");
  sqlite3("REPLACE INTO requests (query,db,md5) VALUES ('$iquery', '$db', '$queryhash')", "requests.db");
  if ($SQL_ERROR) {
    print "Content-type: text/html\n\n";
    print "THIS IS POST\n";
    webdie("SQL ERROR (requests): $SQL_ERROR");
  }
  # and redirect
  print "Location: http://$queryhash.$db.$tld/\n\n";
}

# print the (trivial) form for queries
sub form_request {
  my($db,$tld,$query,$queryhash) = @_;
  debug("FORM_REQUEST($db,$tld,$queryhash)");
  print << "MARK";
<form method='POST' action='http://post.$db.$tld/'><table border>
<tr><th>Enter query below (must start w/ SELECT):</th></tr>
<tr><th><input type="submit" value="RUN QUERY"></th></tr>
<tr><th><textarea name="query" rows=20 cols=79>$query</textarea></th></tr>
<tr><th><input type="submit" value="RUN QUERY"></th></tr>
</form></table>

<p><a href='http://schema.$db.$tld/' target='_blank'>Schema</a>
<a href="http://$db.$tld/$db.db">Raw SQLite3 db</a>
MARK
;

  if ($queryhash) {
    print "<a href='http://rss.$queryhash.$db.$tld'>RSS feed for this query</a>\n";
  }
}

=item schema

SQLite3 schema of tables <h>(sqlite3 is "strongly untyped?")</h>

CREATE TABLE requests ( -- stored query requests
 -- the db column below is redundant but Im ok with that
 query TEXT, -- stored query in MIME64 format
 db TEXT, -- the database for the query
 md5 TEXT -- the query hash
);

CREATE UNIQUE INDEX ui ON requests(md5(32));

=cut

# TODO: move these subroutines to bclib.pl when ready

=item mysql($query,$db)

Run the query $query on the mysql db $db and return results in raw format.

=cut

sub mysql {
  my($query,$db) = @_;
  my($qfile) = (my_tmpfile2());

  # ugly use of global here
  $SQL_ERROR = "";

 # if $query doesnt have ";", add it, unless it starts with "."
  unless ($query=~/^\./ || $query=~/\;$/) {$query="$query;";}
  write_file($query,$qfile);
  debug("WROTE: $query to $qfile");
  my($cmd) = "mysql $db < $qfile";
  my($out,$err,$res,$fname) = cache_command2($cmd,"nocache=1");
  debug("OUT: $out, ERR: $err, RES: $res, FNAME: $fname");

  if ($res) {
    warnlocal("MYSQL returns $res: $out/$err, CMD: $cmd");
    debug("DB is $db", `pwd`);
    $SQL_ERROR = "$res: $out/$err FROM $cmd";
    return "";
  }
  return $out;
}


