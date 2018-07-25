#!/bin/perl

# Another "useful only to me" program (although you can make it useful
# to you by using bc-parse-qfx.pl, MySQL, and categorizing your
# expenses), this program tells me how much I am spending on various
# things, my cash flow, etc.

# This program gets most of its info from command line options

# --income=amount: income per month

# --fixed=cat1=val1,cat2=val2,cat3=val3: treat category spending as
# fixed per month

# --extra=name1=amt1,name2=amt2,name3=amt3,...: extra money I have (or
# owe if negative) that doesn't appear in my databases (the names are
# cosmetic ways of tagging these amounts)

# --exclcat=cat1,cat2,cat3,...: exclude categories from consideration (eg,
# refunded transactions, transactions that move money from one account
# to another, categories that I no longer use + expect no future
# charges for, etc)

# --exclbank=bank1,bank2,bank3,...: exclude these banks from consideration

# --exclcard=card1,card2,card3,...: exclude these credit card from
# consideration

# --start=date: how far back to go when making calculations (default =
# look at all categorized transactions)

require "/usr/local/lib/bclib.pl";

# convert options that are list values to hashes

my(%exclbank) = list2hash(split(/\,/,$globopts{exclbank}));

# TODO: subroutinize?

# how much do I currently owe on my credit cards

# TODO: should really get mysqlval into bclib.pl instead of ugly
# extraction here

# NOTE: breaking this down by card is theoretically unnecessary, but
# helps with debugging

# NOTE: credcardstatements is obsolete, so the '2' below is correct

# TODO: rounding here or should i round later?

# TODO: this amount is slightly wrong because it includes gift cards
# and other weirdnesses; however, it is fairly close

my(@ccowed) = mysqlhashlist("SELECT whichcard, ROUND(SUM(amount),2) AS
total FROM credcardstatements2 GROUP BY whichcard", "test", "user");

# compute total

my($ccowed) = 0; 

for $i (@ccowed) {
  $ccowed += $i->{total};
}

# now, bankstatements (my bank balance, hopefully positive)

my(@bankbals) = mysqlhashlist("SELECT bank, ROUND(SUM(amount),2) AS
total FROM bankstatements GROUP BY bank", "test", "user");

# and total

my($bankbal) = 0;

debug("EXCL", %bankexcl);

for $i (@bankbals) {
  debug("BANK: $i->{bank}");
  if ($exclbank{$i->{bank}}) {next;}
  $bankbal += $i->{total};
}

# TODO: currently assuming I have 0 cash on hand (pretty close to
# true), but try to compute cashtotal accurately later

# this mega query selects all my bank, credit, and cash transactions
# reverse ordered by date

# I don't need all fields, but they are useful for debugging

my($query) = << "MARK";

SELECT amount, date, description AS merchant, category, "bank", oid 
 FROM bankstatements UNION
SELECT amount, date, merchant, category, "credit", oid FROM credcardstatements2
 UNION
SELECT amount, date, merchant, category, "cash", oid FROM cashstatements
ORDER BY date DESC
MARK
;

my(@res) = mysqlhashlist($query, "test", "user");



debug(@res);
