#!/bin/perl

# Trivial variant of bc-parse-ofx3.pl for qfx, which is what I
# shouldve been doing all along?

# --rename: just rename/copy file, do nothing else

# --memoname: show the memo field vs the name field to see if I
# should've been using name instead of memo

# --print1: this is a one off to help me figure out stuff after
# Citibank uses duplicated FITID's, the bastards

require "/usr/local/lib/bclib.pl";
require "/home/user/bc-private.pl";

($all,$name) = cmdfile();

for $i ("ACCTID","DTSERVER","DTSTART","DTEND","DTASOF") {
  $all=~s%<$i>(.*?)<%<$i>$1</$i>\n<%is;
}

# hash data that is fixed for entire file (not per-transaction)
$regex = "acctid|dtserver|dtstart|dtend|dtasof";
$all=~s%<($regex)>\s*(.*?)\s*</\1>%$ofx{$1}=$2%iseg;

# use only first 8 digits of DTASOF, trim leading spaces
$ofx{DTASOF}=~s/^\s*(.{8})(.{6}).*$/$1.$2/s;

debug("DTASOF: $ofx{DTASOF}");

# only use last four digits
$ofx{ACCTID}=~s/^.*(.{4})$/$1/;

# if renaming, just print out appropriate cp statement (too chicken to do mv)

if ($globopts{rename}) {
  print "cp '$name' QFX/$ofx{ACCTID}-$ofx{DTASOF}.qfx\n";
  exit(0);
}

# this is a hack just for me -- one of my credit cards is handled differently

if ($private{notcredit}{$ofx{ACCTID}}) {
  die "Can't use this program on that account";
}

# transactions
while ($all=~s%<STMTTRN>(.*?)</STMTTRN>%%is) {
  $trans = $1;
  %trans = ();
  $trans=~s%<(.*?)>(.*?)(?=<|$)%$trans{$1}=$2%iseg;

  # TODO: ugly hack to trim newlines, should do above
  for $i (keys %trans) {$trans{$i}=trim($trans{$i});}

  $trans{DTPOSTED}=~s/^(\d{4})(\d{2})(\d{2}).*$/$1-$2-$3/;
  unless ($trans{MEMO}=~s/^$ofx{ACCTID}: //) {$trans{MEMO}=$trans{NAME};}

  $trans{MEMO}=~s/\'//g;

  # if just printing stuff, do it here

  if ($globopts{print1}) {
    print "$trans{FITID} $trans{MEMO} $trans{TRNAMT}\n";
    next;
  };

  # if just printing name vs memo, do it here

  if ($globopts{memoname}) {
    print "MEMO: $trans{MEMO}\nNAME: $trans{NAME}\n";
    next;
  }

  # query (credcardstatements2 is new version w/ good indicies, etc)
  push(@queries,
"INSERT IGNORE INTO credcardstatements2
 (whichcard, amount, type, date, transaction_id, merchant) VALUES
 ('$ofx{ACCTID}', $trans{TRNAMT}, '$trans{TRNTYPE}', '$trans{DTPOSTED}',
 '$trans{FITID}', '$trans{MEMO}')");
}

if ($globopts{print1} || $globopts{memoname}) {exit(0);}

# this is probably overkill
# open(A,"|mysql test");
print "BEGIN;\n";
for $i (@queries) {print "$i;\n"}
print "COMMIT;\n";
# close(A);
