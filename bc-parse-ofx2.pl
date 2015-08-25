#!/bin/perl

# Modified version of bc-parse-ofx.pl that uses MySQL, a custom table
# I created ages ago, and credit card statements (instead of generic
# bank statements)

# Options:

# --caponesucks: deal with Capital One errors of not closing tags

require "/usr/local/lib/bclib.pl";

($all,$name) = cmdfile();

# capital one error
if ($globopts{caponesucks}) {
  for $i ("ACCTID","DTSERVER","DTSTART","DTEND") {
    $all=~s%<$i>(.*?)\s%<$i>$1</$i>\n%is;
  }
}

# hash data that is fixed for entire file (not per-transaction)
$regex = "acctid|dtserver|dtstart|dtend";
$all=~s%<($regex)>\s*(.*?)\s*</\1>%$ofx{$1}=$2%iseg;

# only use last four digits
$ofx{ACCTID}=~s/^.*(.{4})$/$1/;

# transactions
while ($all=~s%<STMTTRN>(.*?)</STMTTRN>%%is) {
  $trans = $1;
  %trans = ();
  # <h>obscure code + confusing variable re-use, woohoo!</h>
  if ($globopts{caponesucks}) {
    $trans=~s%<(.*?)>(.*?)\r%$trans{$1}=$2%iseg;
  } else {
    $trans=~s%<(.*?)>(.*?)</\1>%$trans{$1}=$2%iseg;
  }

  # cleanup for MySQL
  $trans{DTPOSTED}=~s/^(\d{4})(\d{2})(\d{2}).*$/$1-$2-$3/;

  # Capital One puts the last four digits of the card number in the
  # MEMO field with the full name of the merchant (but truncates the
  # merchant name in the NAME field), so I use the MEMO field, but cut
  # out the card number
  $trans{MEMO}=~s/^$ofx{ACCTID}: //;

  # query
  push(@queries,
"INSERT IGNORE INTO credcardstatements
 (whichcard, amount, type, date, transaction_id, merchant) VALUES
 ('$ofx{ACCTID}', $trans{TRNAMT}, '$trans{TRNTYPE}', '$trans{DTPOSTED}',
 '$trans{FITID}', '$trans{MEMO}');");
}

debug("QUERIES",@queries);

die "TESTING";

# this is probably stupid
open(A,"|sqlite3 /home/barrycarter/ofx.db");
print A "BEGIN;\n";
for $i (@queries) {print A "$i;\n"}
print A "COMMIT;\n";
close(A);

=item schema

-- Schema for SQLite3 db for above (timestamp always useful)

CREATE TABLE ofxstatements (
 acctid, trnamt, trntype, dtposted, fitid, memo, refnum, category,
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- fitid is only unique per acctid
CREATE UNIQUE INDEX i1 ON ofxstatements(acctid,fitid);

=cut



