#!/bin/perl

# Parse data from predictit.org dumps to put into MySQL sans repeats

require "/usr/local/lib/bclib.pl";

# headers:
# DateExecuted,Type,MarketName,ContractName,Shares,Price,ProfitLoss,Fees,Risk,CreditDebit,URL

while (<>) {

  chomp();

  # use this hash to unique identify the line

  my($hash) = sha1_hex($_);

  my($date, $type, $market, $contract, $shares, $price, $profitloss, $fees, $risk, $creditdebit, $url) = csv($_);

  # fix date to MySQL format

  $date = strftime("%Y-%m-%d %H:%M:%S", localtime(str2time($date))));

  debug($date, $hash);

}


