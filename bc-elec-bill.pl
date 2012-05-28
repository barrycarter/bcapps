#!/bin/perl

# Computes how much my monthly electric bill might be, under a given
# set of assumptions/conditions [assumes I can read my meter's current value]

# Options:
# -norecord: don't record reading in ~/elecbill.txt

require "/usr/local/lib/bclib.pl";

debug(str2time("2012-05-22 08:00:00 MST7MDT"));

die "TESTING";

defaults("norecord=1"); warn "TESTING";

# yyyy-mm-dd when meter last read, and amount
($time,$read) = ("2012-05-22", "50492");
# current time
$now = time();
# current reading (given on cmd line)
(($cur)=@ARGV)||die("Usage: $0 <current_reading>");

unless ($globopts{norecord}) {
  append_file("$now $cur\n", "$ENV{HOME}/elecbill.txt");
}

# I don't know WHEN on $time meter was read, so calculate for both 8am and 5pm
# <h>this is the only really clever bit to this program, assuming there is one</h>

# max and min number of seconds since meter read
$maxtime = $now-str2time("$time 08:00:00 US/Mountain");
$mintime = $now-str2time("$time 17:00:00 US/Mountain");

debug("$mintime/$maxtime");
