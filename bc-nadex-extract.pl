#!/bin/perl -0777

# Extracts data from email NADEX sends; unlikely useful to anyone
# else, but github'ing it anyway

# Usage: pipe message to this program, cut/paste results as appropriate

# my pref format: 13 Oct 2011 205401 USDCAD>1.0320 3PM,14Oct2011 XXXXXXXXXXXXXXX 4*10.75

require "/home/barrycarter/BCGIT/bclib.pl";
use Data::Dumper 'Dumper';

# NADEX is on ET
$ENV{TZ}='EST5EDT';

$all = <STDIN>;

# get fields
while ($all=~s/^(.*?):(.*)$//m) {$hash{$1}=$2;}

# cleanup

# order date
$date = $hash{'Your order was executed on'};
$date=~s/\..*//isg;
$date=strftime("%d %b %Y %H%M%S",localtime(str2time($date)));

# contract
$contract = $hash{'Contract'};
$contract=~s/\(.*//isg;
$contract=~s/[\s\/]//isg;

# expiration
$exp = trim($hash{'Expiration'});
$exp = trim(strftime("%l%p,%d%b%Y",localtime(str2time($exp))));

# trade number
$trade = trim($hash{'to this trade is'});
$trade=~s/\.$//isg;

# quantity and price
$quant = trim($hash{'Quantity'});
$price = trim($hash{'Price'});



print "$date $contract $exp $trade $quant*$price\n"

# print dump_var("whee",\%hash);


