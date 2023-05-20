#!/bin/perl

# parses a bank/credit card balance email

require "/usr/local/lib/bclib.pl";

my($all, $fname) = cmdfile();

# TODO: subroutinize and return hash

# several cleanups

# fix line continuations, kill of HTML and spaces and other garbage
# {} are for CSS

$all=~s/=\n//sg;
$all=~s/<[^<>]*>/ /sg;
$all=~s/\{[^\{\}]*}/ /sg;
$all=~s/(=20|&nbsp;|=0A)/ /isg;
$all=~s/\s*\n+\s*/\n/sg;
$all=~s/(=C2|=A0)//isg;
$all=~s/ +/ /isg;

# debug("ALL: $all");

# TESTING

# if ($all=~s/Your account balance as of (.*?)\s+is\s+(\S+)//isg) {
#   debug("ALPHA: $1, $2");
# }

# die "TESTING";

# these are the "ugly"/raw versions direct from the email

# parsing

my($acct, $date, $amt, $etc);

# if all else fails, use date from mail header

unless ($all=~s/Date: (.*?)\n//) {die("NO DATE: $all");}

$date = $1;

# the $ is ugly because it limits code to USA

# for bluebird, there's an ugly few characters between "Bluebird" and
# "balance" but overmatching matches lines, so limit to a few chars

if ($all=~s/(Balance Amount:|your balance has reached|your balance is|Your Bluebird .{0,20} balance is currently|your chase freedom flex balance is|current balance:|Your Instacart Mastercard balance is|Total balance:|ending balance:|account ending:)\s*(\$\S+)//isg) {

#  debug("1: $1, 2: $2");
  $amt = $2;
}

debug("GAMMA", $all);

if ($all=~s/(Your account balance as of|The balance on your account as of|Your current account balance as of)\s*(.*?)\s*(is|was)\s*(\S+)//isg) {($date, $amt) = ($2, $4);}

debug("ALPHA", $all);

if ($all=~s/(account ending in|card ending in|freedom flex \(\.\.\.|instacart mastercard \(\.\.\.|wells fargo account xxxxxx)\s*(\d+)//is) {
  $acct = $2;
}

debug("FNAME: $fname, ACCT: $acct, BALANCE: $amt, DATE: $date");

# unless ($amt) {die("NO BALANCE!");}
