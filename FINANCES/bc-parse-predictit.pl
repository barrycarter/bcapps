#!/bin/perl

# Parse data from predictit.org dumps to put into MySQL sans repeats

require "/usr/local/lib/bclib.pl";

# headers:
# DateExecuted,Type,MarketName,ContractName,Shares,Price,ProfitLoss,Fees,Risk,CreditDebit,URL

while (<>) {

  chomp($_);
  s/\r//g;

  # use this hash to unique identify the line

  my($hash) = sha1_hex($_);

  my($date, $type, $market, $contract, $shares, $price, $profitloss, $fees, $risk, $creditdebit, $url) = csv($_);

  # fix date to MySQL format

  $date = strftime("%Y-%m-%d %H:%M:%S", localtime(str2time($date)));

  # convert $type (like "Sell Yes") to two fields

  my($bs, $yn) = split(/\s+/, $type);

  # for market and contract, just remove apostrophes

  $market=~s/\'//g;

  $contract=~s/\'//g;

  # for price, just remove $ (TODO: check between 0.01 and 0.99?)

  $price=~s/\$//g;

  # profitloss only applies to closing transactions and I could theoretically calculate it... format is $10.68 or ($123.44)

  $profitloss = fixval_local($profitloss); 

  $fees = fixval_local($fees);

  $creditdebit = fixval_local($creditdebit);

  $risk = fixval_local($risk);

  print "INSERT IGNORE INTO predictit (date, buysell, yesno, market, contract, shares, price, profitloss, fees, risk, creditdebit, url, hash)\n";

  print "VALUES ('$date', '$bs', '$yn', '$market', '$contract', '$shares', '$price', '$profitloss', '$fees', '$risk', '$creditdebit', '$url', '$hash');\n";

}

# one off to change things like $10.68 to 10.68 or ($123.44) to -123.44

sub fixval_local {

  my($num) = @_;

  $num=~s/\$//g;

  if ($num=~s/\((.*?)\)/$1/) {$num *= -1;}

  return $num;

}

=item sql

Table:

DROP TABLE IF EXISTS predictit;

CREATE TABLE predictit (
 oid INT UNSIGNED NOT NULL AUTO_INCREMENT,
 INDEX(oid),
 date DATETIME,
 buysell TEXT,
 yesno TEXT,
 market TEXT,
 contract TEXT,
 shares DOUBLE,
 price DOUBLE,
 profitloss DOUBLE,
 fees DOUBLE,
 risk DOUBLE,
 creditdebit DOUBLE,
 url TEXT,
 hash TEXT
);

CREATE UNIQUE INDEX i1 ON predictit(hash(50));

=cut
