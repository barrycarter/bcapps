#!/usr/bin/perl -0777

# run an arbitrary readonly MySQL query webapp
# TODO: add RSS and CSV and dl entire db options; rushing to
# "production" for now
# format: [rss|csv|].[query|"schema"].db.(db|database).other.stuff

require "/usr/local/lib/bclib.pl";

# TODO: do not do this
# $globopts{keeptemp}=1;

# the only constant is .db|database.
$ENV{HTTP_HOST}=~/^(.*?)\.(db|database)\.(.*)$/;
my($base, $tld) = ($1,"$2.$3");

# determine query pieces (reversed because lower parts don't always exist)
my($db, $query, $type) = reverse(split(/\./, $base));

# this is bad long term
unless ($db eq "shared") {print "Location: http://shared.$tld\n\n"; exit;}

if ($query eq ""){print "Content-type: text/html\n\n";form_request($db,$tld);}
elsif ($query eq "schema") {schema_request($db,$tld);}
elsif ($query eq "post") {post_request($db,$tld);}
elsif ($query=~/[0-9a-f]{32}$/) {query_request($query,$db,$tld,$type);}
else {
webdie("Hostname $ENV{HTTP_HOST} not understood", "Content-type: text/html");
}

# this subroutines are specific to this program thus not well documented
sub schema_request {
  my($db,$tld) = @_;
  my($out,$err,$res) = cache_command2("mysqldump --no-data $db");
  if ($res) {webdie("Schema error: $res/$out/$err","Content-type: text/html");}
  print "Content-type: text/plain\n\n$out\n";
}

# request for query already in requests.requests
sub query_request {
  my($hash,$db,$tld,$format) = @_;
  my($options);
  my($query) = decode_base64(mysqlval("SELECT query FROM requests WHERE md5='$hash' AND db='$db'", "requests"));

  # no query returned?
  unless ($query) {
    webdie("$db exists, but no query with hash $hash. Try http://$db.$tld/","Content-type: text/html");
  }

  # actually run query (use tmpfile to avoid command line danger)
  my($tmp) = my_tmpfile("dbquery");
  write_file("$query;", $tmp);

  # options based on format
  $options="-H";
  if ($format eq "csv") {$options="-B"};
  if ($format eq "rss") {$options="-X"};

  # avoid DOS by limiting cputime
  my($out,$err,$res) = cache_command2("ulimit -t 5 && mysql $options $db < $tmp");

  # restore hyperlinks and quotes
  $out=~s/&lt;/</isg;
  $out=~s/&gt;/>/isg;
  $out=~s/&quot;/\"/isg;
  $out=~s/&\#39;/\'/isg;

  # error?
  if ($res) {webdie("QUERY: $query<br>ERROR: $err","Content-type: text/html");}

  # result is known good
  if ($format eq "csv") {
    $out=~s/\t/,/isg;
    $out="Content-type: text/plain\n\n$out\n";
    print $out;
    return;
  }

  # this doesnt actually work right now
  if ($format eq "rss") {
    $out="Content-type: text/xml\n\n$out\n";
    print $out;
    return;
  }

  # info about db
  # TODO: defeat for CSV?
  print read_file("$db.txt");
  print << "MARK";
Content-type: text/html

<a href="#query">See/edit your query</a>

<p><table border>
$out
</table><p>
MARK
;
    form_request($db,$tld,$query,$hash);
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
  # TODO: restore this!
  unless ($query=~/^select/i) {
    webdie("Query doesn't start w SELECT: $query");
  }

  # permitted characters (is this going to end up being everything?)
  if ($query=~/([^a-z0-9_: \(\)\,\*\<\>\"\'\=\.\/\?\|\!\+\-\%\\])/i) {
    webdie("Query contains illegal character '$1': $query");
  }

  # query is now safe, add to requests.db (as base 64)
  my($iquery) = encode_base64($query);
  chomp($iquery);
  my($queryhash) = md5_hex($iquery);
  # TODO: if query already in db, need to do this (or pointless?)
  mysql("REPLACE INTO requests (query,db,md5) VALUES ('$iquery', '$db', '$queryhash')", "requests");
  if ($SQL_ERROR) {
    webdie("SQL ERROR (requests): $SQL_ERROR");
  }
  # and redirect
  print "Location: http://$queryhash.$db.$tld/\n\n";
}

# print the (trivial) form for queries
sub form_request {
  my($db,$tld,$query,$queryhash) = @_;
  print << "MARK";
<a name="query">
<form method='POST' action='http://post.$db.$tld/'><table border>
<tr><th>Enter query below (must start w/ SELECT):</th></tr>
<tr><th><input type="submit" value="RUN QUERY"></th></tr>
<tr><th><textarea name="query" rows=20 cols=79>$query</textarea></th></tr>
<tr><th><input type="submit" value="RUN QUERY"></th></tr>
</form></table>

<p><a href='http://schema.$db.$tld/' target='_blank'>Schema</a>
MARK
;

  if ($queryhash) {
    print "<a href='http://rss.$queryhash.$db.$tld'>XML</a>\n"; 
    print "<a href='http://csv.$queryhash.$db.$tld'>CSV</a>\n";
 }
}

=item schema

Schema of tables and users (keep requests in an unshared db intentionally):

CREATE DATABASE shared;
CREATE DATABASE requests;
\u requests
CREATE TABLE requests (
 query TEXT, -- stored query in MIME64 format
 db TEXT, -- the database for the query
 md5 TEXT -- the query hash
);

CREATE UNIQUE INDEX ui ON requests(md5 (32));

-- TODO: change "test" to the db Ill actually want to use
CREATE USER readonly;
GRANT SELECT ON shared.* TO 'readonly'@'localhost';
GRANT SELECT,INSERT,DELETE ON requests.* TO 'readonly'@'localhost';

=cut

# TODO: move these subroutines to bclib.pl when ready

=item mysql($query,$db,$user="readonly")

Run the query $query on the mysql db $db as user $user and return
results in "raw" format.

TODO: remove the hardcoded 'readonly' before generalizing this function

=cut

sub mysql {
  my($query,$db,$user) = @_;
  unless ($user) {$user = "readonly";}
  my($qfile) = (my_tmpfile2());

  # ugly use of global here
  $SQL_ERROR = "";

  write_file($query,$qfile);
  my($cmd) = "mysql -u $user -E $db < $qfile";
  my($out,$err,$res,$fname) = cache_command2($cmd,"nocache=1");
  # get rid of the row numbers + remove blank first line
  $out=~s/^\*+\s*\d+\. row\s*\*+$//img;
  $out = trim($out);

  if ($res) {
    warnlocal("MYSQL returns $res: $out/$err, CMD: $cmd");
    debug("DB is $db", `pwd`);
    $SQL_ERROR = "$res: $out/$err FROM $cmd";
    return "";
  }
  return $out;
}

=item mysqlval($query,$db)

For queries that return a single row/column, return that row/column

# TODO: this implementation is painfully ugly

=cut

sub mysqlval {
  my($query,$db) = @_;
  my(@res) = mysql($query,$db);
  $res[0]=~s/^.*?:\s+//;
  return $res[0];
  # get rid of leading row of stars
  # TODO: if I were really clever, I could combine the two lines below!
  my(@temp) = values %{$res[0]};
  return $temp[0];
}
