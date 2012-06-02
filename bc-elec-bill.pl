#!/bin/perl

# Computes how much my monthly electric bill might be, under a given
# set of assumptions/conditions [assumes I can read my meter's current value]

# Options:
# --norecord: don't record reading in ~/elecbill.txt
# --last: use last reading in ~/elecbill.txt, not new measurement

# TODO:
# add --last option that just shows results from previous reading
# show "what if" scenarios
# measure usage since last reading(s)
# add +-1 minute inaccuracy in reading time (though 8h window sort of covers this)
# allow --time= entries for previous times
# report out of order readings?
# add "median" estimates too?

require "/usr/local/lib/bclib.pl";

# useful constants
$secspermonth = 365.2425*86400/12; # gregorian

# sort (just in case of out-of-order entries in the future)
system("sort -n $ENV{HOME}/elecbill.txt -o $ENV{HOME}/elecbill.txt");

# tiered usage cost (first 450 at .0906, next 450 at .1185, rest at .1284)
# http://www.nmprc.state.nm.us/consumer-relations/company-directory/electric/pnm/forms/form90.pdf is accurate, at least for May 2012
# TODO: this doesn't need to be a constant
@tiers = ([450, 0.0906237], [450, 0.1185101], [+Infinity, 0.1283520]);

# yyyy-mm-dd when meter last read, and amount
# TODO: this obviously shouldn't be hardcoded
($time,$read) = ("2012-05-22", "50492");

# min and max time read, assuming meter was read 8a-5p
$minreadtime = str2time("$time 08:00:00 MST7MDT");
$maxreadtime = str2time("$time 17:00:00 MST7MDT");

# if reading from file...
if ($globopts{last}) {
  my($out,$err,$res) = cache_command("tail -1 $ENV{HOME}/elecbill.txt");
  ($now, $cur) = split(/\s+/, $out);
} else {
  # current time
  $now = time();
  # current reading (given on cmd line)
  (($cur)=@ARGV)||die("Usage: $0 <current_reading>");

  unless ($globopts{norecord}) {
    append_file("$now $cur\n", "$ENV{HOME}/elecbill.txt");
  }
}

# I don't know WHEN on $time meter was read, so calculate for both 8am and 5pm
# <h>this is the only really clever bit to this program, assuming there is one</h>

# max and min number of seconds since meter read
$maxtime = $now-$minreadtime;
$mintime = $now-$maxreadtime;

# look at last few entries and determine usage
open(A,"tac $ENV{HOME}/elecbill.txt|"); 

while (<A>) {
  my($rtime, $reading) = split(/\s+/, $_);

  # ignore readings older than last known reading
  if ($rtime < $maxreadtime) {last;}

  # compare to most recent reading
  $elapsed = $now - $rtime;
  $used = $cur - $reading;
  elec_stats($used, $elapsed);
}

close(A);

# average kilowatt usage (reading is in kilowatthours)
# allow .1 fudge in reading
$max = ($cur+.1-$read)/$mintime*3600;
$min = ($cur-.1-$read)/$maxtime*3600;

debug("MAX/MIN: $max/$min");

# per month (365.2425 days in a year, Gregorian calendar)
($monthmin, $monthmax) = ($min*$secspermonth/3600, $max*$secspermonth/3600);
($costmin, $costmax) = (tiered_cost($monthmin), tiered_cost($monthmax));

printf("Last reading: %s\n", $time);
printf("Usage to date: %d (\$%.2f)\n", $cur-$read, tiered_cost($cur-$read));
printf("Average usage: %d - %d watts (J/s)\n",$max*1000,$min*1000);
printf("Monthly usage: %d - %d kwh\n",$monthmin,$monthmax);
printf("Cost: \$%.2f - \$%.2f\n",$costmin,$costmax);

# work out cost of $n kilowatthours of electricity, using tiers
sub tiered_cost {
  my($n) = @_;

  my($total) = 0;
  for $i (@tiers) {
    my($tier,$price) = @$i;

    # if not used up entire tier, return
    if ($n < $tier) {return $total+$n*$price;}

    # used up entire tier, so keep going
    $total += $tier*$price;
    $n -= $tier;
  }
}

# given kwh usage and number of seconds, print out (TODO: blech!)
# information about usage, allowing for +-.1 error in reading and
# +-60s error in time [per reading]

sub elec_stats {
  my($usage, $sec) = @_;
  debug("elec_stats($usage,$sec)");

  # max and min seconds (+-60s each way, so total 120s)
  my($minsec, $maxsec) = ($sec-120, $sec+120);
  # and usage (+-.1 each way, so .2 total)
  my($minuse, $maxuse) = ($usage-.2, $usage+.2);

  # maximum and minimum usage (in watts)
  my($maxwatts) = $maxuse/$minsec*3600*1000;
  my($minwatts) = $minuse/$maxsec*3600*1000;

  debug("RANGE: $minwatts-$maxwatts");

  # number of seconds left this month
  my($secsleftmax) = $secspermonth - $mintime;
  my($secsleftmin) = $secspermonth - $maxtime;

  # we could do +-.1 on current reading, but it won't really matter
  my($usagetodate) = ($cur-$read);

  # max and min estimated usage for month
  my($maxusage) = $usagetodate + ($secsleftmax*$maxwatts)/3600000;
  my($minusage) = $usagetodate + ($secsleftmin*$minwatts)/3600000;

  debug("MINMAX: $minusage-$maxusage");

  # and price
  my($maxprice) = tiered_cost($maxusage);
  my($minprice) = tiered_cost($minusage);

  debug("MINMAX: $minprice-$maxprice");

  # TODO: subroutines printing is bad!
print << "MARK";

Usage (since $time): $usagetodate
Average (last $minsec-$maxsec seconds): $minwatts-$maxwatts
Total usage for month: $minusage-$maxusage
Total cost for month: $minprice-$maxprice
MARK
;

}

