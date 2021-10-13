#!/bin/perl

# Will eventually tell me how much bandwidth I've used and how much is
# left for the month

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/BCPRIV/bc-private.pl";

# these variables are not private- since xfinity doesnt break out RX
# and TX (and I don't really need to either, replacing with $opxfer)

my($iface) = $private{iface};
my($optotal) = $private{bandwidth};
my($opdate) = $private{bwtime};

# this is Comcast's limit on free bandwidth (TODO: put in priv?)

my($bwlimit) = 1229*10**9;

# currently assuming 31 days for all months, perhaps adjust later
# TODO: make this more accurate

my($days) = 31;

######## end config here ########

my($now) = time();

my($out, $err, $res) = cache_command2("ifconfig", "age=60");

# extract out data for this interface

$out=~/$iface:(.*?)\n\n/s;
my($details) = $1;

# get just the data I want

unless ($details=~/RX packets \d+\s+bytes\s+(\d+)/) {
  die("Couldn't get RX bytes");
}

$rx = $1;

unless ($details=~/TX packets \d+\s+bytes\s+(\d+)/) {
  die("Couldn't get TX bytes");
}

$tx = $1;

my($total) = $rx + $tx;

my($used) = $total-$optotal;

my($time) = $now-$opdate;

# how much I would use in a month at this rate

my($proj) = $used/$time*86400*$days;

# print out how it compares to allowed usage, but also print out total
# usage for month to date

printf("Used: %0.2f GB (of %0.2f GB, %0.2f%% total, %0.2f days \@ 95%) in %0.2f days\nProj: %0.2f%%\n", $used/10**9, $bwlimit/10**9, $used/$bwlimit*100, $used/$bwlimit*$days/.95, ($now-$opdate)/86400, $proj/$bwlimit*100);

# TODO: add error alert if projected > 95%

