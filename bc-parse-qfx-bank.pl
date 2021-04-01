#!/bin/perl

# Trivial bariant of bc-parse-qfx.pl for bank stuff, which has a
# slightly different format

# Trivial variant of bc-parse-ofx3.pl for qfx, which is what I
# shouldve been doing all along?

require "/usr/local/lib/bclib.pl";
require "/home/user/bc-private.pl";

($all,$name) = cmdfile();

for $i ("ACCTID","DTSERVER","DTSTART","DTEND") {
  $all=~s%<$i>(.*?)<%<$i>$1</$i>\n<%is;
}

# hash data that is fixed for entire file (not per-transaction)
$regex = "acctid|dtserver|dtstart|dtend";
$all=~s%<($regex)>\s*(.*?)\s*</\1>%$ofx{$1}=$2%iseg;

# only use last four digits
$ofx{ACCTID}=~s/^.*(.{4})$/$1/;

debug(%ofx);

# this is a hack just for me -- one of my credit cards is handled differently

# but if it's NOT a credit card, it's a bank (just go with it)

unless ($private{notcredit}{$ofx{ACCTID}}) {
  die "Can't use this program on that account";
}

# transactions
while ($all=~s%<STMTTRN>(.*?)</STMTTRN>%%is) {
  $trans = $1;
  %trans = ();
  $trans=~s%<(.*?)>(.*?)(?=<|$)%$trans{$1}=$2%iseg;

  # TODO: ugly hack to trim newlines, should do above
  for $i (keys %trans) {$trans{$i}=trim($trans{$i});}

  # for some accounts, I have the same FITID across 2 accounts (which
  # is probably ok); as a hack, I add the acct number to the FITID in
  # these cases since bankstatments requires a unique value for
  # unique_id (except when NULL)

  if ($private{useacctfit}{$ofx{ACCTID}}) {$trans{FITID} .= "-$ofx{ACCTID}";}

  $trans{DTPOSTED}=~s/^(\d{4})(\d{2})(\d{2}).*$/$1-$2-$3/;
  unless ($trans{MEMO}=~s/^$ofx{ACCTID}: //) {$trans{MEMO}=$trans{NAME};}

  $trans{MEMO}=~s/\'//g;

  # query (credcardstatements2 is new version w/ good indicies, etc)
  push(@queries,
"INSERT IGNORE INTO bankstatements
 (bank, amount, type, date, unique_id, description) VALUES
 ('$ofx{ACCTID}', $trans{TRNAMT}, '$trans{TRNTYPE}', '$trans{DTPOSTED}',
 '$trans{FITID}', '$trans{MEMO}')");
}

# this is probably overkill
# open(A,"|mysql test");
print "BEGIN;\n";
for $i (@queries) {print "$i;\n"}
print "COMMIT;\n";
# close(A);
