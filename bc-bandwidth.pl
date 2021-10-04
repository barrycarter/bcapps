#!/bin/perl

# Will eventually tell me how much bandwidth I've used and how much is
# left for the month

require "/usr/local/lib/bclib.pl";

# TODO: these variables, representing the network interface and last
# measured bandwidth and date, should be customizable (eg, in BCPRIV)

my($iface) = "enp11s0";

# TODO: I'm not sure what Xfinity considers "start of month" so
# fudging with tese values for now

# my($oprx) = 99575773347;
# my($optx) = 34708223531;
# my($opdate) = str2time("Thu Sep 30 18:16:01 MDT 2021");

# my($oprx) = 100558729688;
# my($optx) = 34791512372;
# my($opdate) = str2time("Fri Oct  1 00:16:01 MDT 2021");

# this is most accurate for some weird reason

my($oprx) = 106819023137;
my($optx) = 37568752594;
my($opdate) = str2time("Fri Oct  1 08:16:02 MDT 2021");

# this is Comcast's limit on free bandwidth

my($bwlimit) = 1229*10**9;

# currently assuming 31 days for all months, perhaps adjust later

my($days) = 31;

debug("OP: $oprx, $optx, $opdate");

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

debug($rx, $tx);

my($total) = $rx + $tx;

my($optotal) = $oprx + $optx;

my($used) = $total-$optotal;

my($time) = $now-$opdate;

# how much I would use in a month at this rate

my($proj) = $used/$time*86400*$days;

# print out how it compares to allowed usage, but also print out total
# usage for month to date

printf("Used: %0.2f GB (of %0.2f GB, %0.2f%% of total, %0.2f days at 95%) in %0.2f days\nProj: %0.2f%%\n", $used/10**9, $bwlimit/10**9, $used/$bwlimit*100, $used/$bwlimit*$days/.95, ($now-$opdate)/86400, $proj/$bwlimit*100);

# TODO: add error alert if projected > 95%

