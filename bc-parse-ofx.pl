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
"INSERT IGNORE INTO ofxstatements
 (acctid, trnamt, trntype, dtposted, fitid, memo, refnum) VALUES
 ('$ofx{ACCTID}', $trans{TRNAMT}, '$trans{TRNTYPE}', '$trans{DTPOSTED}',
 '$trans{FITID}', '$trans{MEMO}', '$trans{REFNUM}')");
}


debug(@queries);





