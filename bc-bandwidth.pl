#!/bin/perl

# Will eventually tell me how much bandwidth I've used and how much is
# left for the month

require "/usr/local/lib/bclib.pl";

# TODO: these variables, representing the network interface and last
# measured bandwidth and date, should be customizable (eg, in BCPRIV)

my($iface) = "enp11s0";

# TODO: I'm not sure what Xfinity considers "start of month" so
# fudging with tese values for now

my($oprx) = 99575773347;
my($optx) = 34708223531;
my($opdate) = str2time("Thu Sep 30 18:16:01 MDT 2021");

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


