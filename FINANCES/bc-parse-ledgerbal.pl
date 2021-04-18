#!/bin/perl

# given an QFX file, find the account number, ledger balance, and date of ledgerbalance

require "/usr/local/lib/bclib.pl";

my($all, $name) = cmdfile();

# the acctid tag doesn't necessarily have an end tag, ledgerbal always does

unless ($all=~s%<acctid>(.*?)<%%is) {die "NO ACCTID";}

my($acctid) = $1;

unless ($all=~s%(<ledgerbal>.*?</ledgerbal>)%%is) {die "NO LEDGERBAL";}

my($ledger) = $1;

unless ($ledger=~s%<balamt>(.*?)<%<%is) {die "NO BALAMT";}

my($balamt) = $1;

unless ($ledger=~s%<dtasof>(.*?)<%%is) {die "NO DTASOF";}

my($dtasof) = $1;

debug("$acctid, $balamt, $dtasof");


