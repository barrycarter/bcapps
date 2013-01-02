#!/bin/perl

# Given a (currently fixed) SQLite3 db/table, create an insert form for it

# NOTE: decided to pretty much do this from scratch instead of trying
# to replicate my former PHP/MySQL thing

require "/usr/local/lib/bclib.pl";

print "Content-type: text/html\n\n";

$tabname = "foods";
$db = "/home/barrycarter/BCINFO/sites/DB/myfoods.db";

my(%cols) = sqlite3cols($tabname, $db);

print "<form method='POST' action='bc-insertrow-sqlite3.pl'><table border>\n";

# TODO: order?
for $i (keys %cols) {
  print "<tr><th>$i</th><td><input type='text' name='$i' size=80 /></td>\n";
}

print "<tr><th colspan=2><input type='submit' value='SUBMIT'></th></tr>\n";
print "</table></form>\n";
