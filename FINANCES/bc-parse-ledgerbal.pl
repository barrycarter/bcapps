#!/bin/perl

# given an QFX file, find the account number, ledger balance, and date of ledgerbalance

require "/usr/local/lib/bclib.pl";

my($all, $name) = cmdfile();

debug("FILENAME: $name");

# the acctid tag doesn't necessarily have an end tag, ledgerbal always does

unless ($all=~s%<acctid>(.*?)<%%is) {die "NO ACCTID";}

my($acctid) = $1;

# last 4 digits only

unless ($acctid=~s%^.*(\d{4})\s*$%$1%s) {
  die("BAD ACCTID: $acctid");
}

unless ($all=~s%(<ledgerbal>.*?</ledgerbal>)%%is) {die "NO LEDGERBAL";}

my($ledger) = $1;

unless ($ledger=~s%<balamt>(.*?)<%<%is) {die "NO BALAMT";}

my($balamt) = trim($1);

unless ($ledger=~s%<dtasof>(.*?)<%%is) {die "NO DTASOF";}

my($dtasof) = trim($1);

# convert to MySQL format (this may lose timezone information)

$dtasof=~s/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2}).*$/$1-$2-$3 $4:$5:$6/s;

debug($dtasof);

print "INSERT IGNORE INTO ledger_balances (acctid, balamt, dtasof) VALUES
 ('$acctid', '$balamt', '$dtasof');\n";

# debug("$acctid, $balamt, $dtasof");

=item schema

CREATE TABLE ledger_balances (
 acctid TEXT, balamt DOUBLE, dtasof DATETIME,
 comments TEXT,  oid INT UNSIGNED NOT NULL AUTO_INCREMENT,
 timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, INDEX(oid)
);

CREATE UNIQUE INDEX i1 ON ledger_balances(acctid(16), balamt, dtasof);

=cut

