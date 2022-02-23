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

# Comcast MAY use gibibyte definition, so allowing it to be variable (and testing gibibyte for a while)

my($gig) = 2**30;

warn("TESTING gibibyte");

# this is Comcast's limit on free bandwidth (TODO: put in priv?)

my($bwlimit) = 1229*$gig;

######## end config here ########

my($now) = time();

# this is ugly... 

# first, find info on current date/time

my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($now);

# create time for noon on first day of next month, subtract one day,
# and suck out day number

# if month is 12, advance year too

if (++$mon>12) {$year++; $mon-=12;}

my(@ltime) = gmtime(mktime(0, 0, 12, 1, $mon, $year)-86400);

# cheating because we know ltime[3] is what we want

my($days) = $ltime[3];

debug("DAYS THIS MONTH: $days");

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

printf("Used: %0.2f GB (of %0.2f GB, %0.2f%% total, %0.2f days \@ 95%) in %0.2f days\nProj: %0.2f%%\n", $used/$gig, $bwlimit/$gig, $used/$bwlimit*100, $used/$bwlimit*$days/.95, ($now-$opdate)/86400, $proj/$bwlimit*100);

# TODO: add error alert if projected > 95%

