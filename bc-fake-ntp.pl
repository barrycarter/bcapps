#!/bin/perl

# my own personal version of ntpd after I get sick of the real one
# 6553600 freq = 1 tick = 8.64s/day = 0.36s/hour = 1/10000

# --offset==x: assume offset is x, don't query timeserver
# --interval==i: assume program is run every i seconds (default 3600)

if ($>) {die("Must be root");}
push(@INC,"/usr/local/lib");
require "bclib.pl";

# set interval (how often this prog is run)
# this is probably the wrong way to default a value
$interval=$globopts{interval}||3600;

# current time and timeservers to query (4 is really too many)?
$now=time();
$TIMESERVER="0.us.pool.ntp.org 1.us.pool.ntp.org 2.us.pool.ntp.org 3.us.pool.ntp.org";

# find old values (if any)
$af=`tail -1 /root/adjtimex.txt`;
($oldtime,$oldoffset,$oldtick,$oldfreq)=split(/\s+/,$af);
$oldtickx=$oldtick+$oldfreq/6553600;

# current offset
if ($globopts{offset}) {
  $curoffset=$globopts{offset};
} else {
  # caching an ntpdate command is silly, but useful for testing
  cache_command("ntpdate -d $TIMESERVER > /var/tmp/ntpdate.txt","age=60");
  $ad=`egrep ' offset ' /var/tmp/ntpdate.txt`;
  if ($ad=~/offset\s+([\-\d\.]+)/) {
    debug("NTPoffset: $ad");
    $curoffset=$1;
  } else {
    warn("No offset available, assuming 0");
    $curoffset=0;
  }
}

# #seconds we want to gain next interval minus number we'd gain at current rate
$gain=$curoffset+$interval*($curoffset-$oldoffset)/($now-$oldtime);
$newtickx=$oldtickx+10000*($gain/$interval);

# adjust newtickx, extract newtick, newfreq (min/max rules)
$newtickx=max(min($newtickx,11000),9000);
$newtick=int($newtickx);
$newfreq=int(($newtickx-$newtick)*6553600+.5);

$ac="adjtimex --tick $newtick --freq $newfreq";
# die "TESTING: $ac";
open(A,">>/root/adjtimex.txt");
print A "$now $curoffset $newtick $newfreq\n";
close(A);
system($ac);
