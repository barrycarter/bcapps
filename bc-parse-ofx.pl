#!/bin/perl

# Parses arbitrary OFX and inserts results into database table

require "/usr/local/lib/bclib.pl";

($all,$name) = cmdfile();

# hash data that is fixed for entire file (not per-transaction)
$regex = "acctid|dtserver|dtstart|dtend";
$all=~s%<($regex)>\s*(.*?)\s*</\1>%$ofx{$1}=$2%iseg;

# transactions
while ($all=~s%<STMTTRN>(.*?)</STMTTRN>%%is) {
  $trans = $1;
  %trans = ();
  # <h>obscure code + confusing variable re-use, woohoo!</h>
  $trans=~s%<(.*?)>(.*?)</\1>%$trans{$1}=$2%iseg;

  debug("TRANS",%trans);

  # query
  push(@queries,
"INSERT OR REPLACE INTO ofxstatements
 (acctid, trnamt, trntype, dtposted, fitid, memo, refnum) VALUES
 ('$ofx{ACCTID}', $trans{TRNAMT}, '$trans{TRNTYPE}', '$trans{DTPOSTED}',
 '$trans{FITID}', '$trans{MEMO}', '$trans{REFNUM}')");
}

# this is probably stupid
open(A,"|sqlite3 /home/barrycarter/ofx.db");
print A "BEGIN;\n";
for $i (@queries) {print A "$i;\n"}
print A "COMMIT;\n";
close(A);

=item schema

-- Schema for SQLite3 db for above (timestamp always useful)

CREATE TABLE ofxstatements (
 acctid, trnamt, trntype, dtposted, fitid, memo, refnum, 
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- fitid is only unique per acctid
CREATE UNIQUE INDEX i1 ON ofxstatements(acctid,fitid);

=cut



