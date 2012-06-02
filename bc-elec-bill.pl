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

# useful constants/vars
$secspermonth = 365.2425*86400/12; # gregorian
$elecfile = "$ENV{HOME}/elecbill.txt";

# sort (just in case of out-of-order entries in the future)
system("sort -n $elecfile -o $elecfile");

# tiered usage cost (first 450 at .0906, next 450 at .1185, rest at .1284)
# http://www.nmprc.state.nm.us/consumer-relations/company-directory/electric/pnm/forms/form90.pdf is accurate, at least for May 2012
# TODO: this doesn't need to be a constant
@tiers = ([450, 0.0906237], [450, 0.1185101], [+Infinity, 0.1283520]);

# yyyy-mm-dd when meter last read, and amount
# TODO: this obviously shouldn't be hardcoded
($time,$read) = ("2012-05-22", "50492");

# ranges are now represented as [low, med, high] where med = the
# "true" reading in some sense; 12:30pm = center of 8-5 day
$readtime = str2time("$time 12:30:00 MST7MDT");
@readtime = ($readtime-4.5*3600, $readtime, $readtime+4.5*3600);
@read = ($read-.1, $read, $read+.1);

# if reading from file...
if ($globopts{last}) {
  my($out,$err,$res) = cache_command("tail -1 $elecfile");
  ($now, $cur) = split(/\s+/, $out);
  debug("CUR: $cur");
  print strftime("Using: %x %X\n", localtime($now));
} else {
  # current time
  $now = time();
  # current reading (given on cmd line)
  (($cur)=@ARGV)||die("Usage: $0 <current_reading>");

  unless ($globopts{norecord}) {
    append_file("$now $cur\n", "$elecfile");
  }
}

# give or take 1 minute
@now = ($now-60, $now, $now+60);
# give or take .1
@cur = ($cur-.1, $cur, $cur+.1);

# number of seconds since meter read
@time = ($now[0]-$readtime[2], $now[1]-$readtime[1],$now[2]-$readtime[0]);

# time to end of month
@timeleft = ($now[2]-$readtime[0], $now[1]-$readtime[1], $now[0]-$readtime[2]);
for $i (@timeleft) {$i = $secspermonth-$i;}

# look at last few entries and determine usage
open(A,"tac $elecfile|");

# create plotfile for gnuplot, beats:
# echo plot \'-\' with linespoints; tail -10 ~/elecbill.txt) | gnuplot -persist
# TODO: add reference lines?
open(B,">/tmp/gnuplot.txt");

while (<A>) {
  my($rtime, $reading) = split(/\s+/, $_);

  # ignore readings older than last known reading (otherwise, run risk
  # of negative usage)
  if ($rtime < $readtime[2]) {last;}

  # plotting in seconds is ugly, so go with days ago (gnuplot)
  # TODO: could do this for even older readings?
  debug("RTIME: $rtime, READ: $read[2]");
  $plotdays = sprintf("%.2f", ($now-$rtime)/86400);
  print B "$plotdays $reading\n";

  # standard 60 second and +-.1 kwh
  @rtime = ($rtime-60, $rtime, $rtime+60);
  @reading = ($reading-.1, $reading, $reading+.1);
  
  # no longer sure how useful elec_stats() is, so leaving it disabled
  # TODO: reconsider elec_stats
  #  elec_stats(\@rtime, \@reading);
}

close(A);
close(B);

# usage in kwh so far this month
@usagekwh = ($cur[0]-$read[2], $cur[1]-$read[1], $cur[2]-$read[0]);

# average kilowatt usage (reading is in kilowatthours)
# TODO: PNM only reads to nearest .5, but using .1 below
@usage =(($usagekwh[0]/$time[2],$usagekwh[1]/$time[1],$usagekwh[2]/$time[0]));

# above is kilowatthours/second (joules), so multiple
# <h>one day, I hope to learn how to use the map command!</h>
for $i (@usage) {$i*=3600000;}

# TODO: include all intrahour reading diffs, or just current vs those?

# per month
for $i (@usage) {push(@month, $i*$secspermonth/3600000);}
for $i (@month) {push(@cost, tiered_cost($i));}

debug("NOW",@now);
debug("CUR",@cur);
debug("READTIME",@readtime);
debug("TIME",@time);
debug("USAGE",@usage);
debug("USAGEKWH",@usagekwh);
debug("MONTH",@month);
debug("COST",@cost);
debug("TIMELEFT",@timeleft);

# time in days for printing
for $i (@time) {push(@timeindays,$i/86400.);}

printf("Last PNM reading: %s\n", $time);
printf("Usage to date (kwh): %.1f (%.1f - %.1f)\n", @usagekwh[1,0,2]);
printf("Days since last reading: %.2f (%.2f - %.2f)\n", @timeindays[1,0,2]);
printf("Usage (watts): %d (%d - %d)\n", @usage[1,0,2]);
printf("Usage for month (kwh): %d (%d - %d)\n",@month[1,0,2]);
printf("Cost: \$%.2f (\$%.2f - \$%.2f)\n",@cost[1,0,2]);

# separator
print "\n";

# if/thens if we assume different wattage for rest of month
# using 10K watts is hard, but I've hit ~8K before, so not unreasonable
for $i (0..20) {
  # note that $i=0 also gives current usage
  $watts = $i*500;

  # total usage for month would be this (in kwh) and cost
  @hypusage=();
  @hyprice=();
  for $i (0..2) {
    my($hypwatts) = $timeleft[$i]*$watts/3600000 + $usagekwh[$i];
    push(@hypusage, $hypwatts);
    push(@hyprice, tiered_cost($hypwatts));
  }

  debug("$watts watts:",@hypusage,"price",@hyprice);

  printf("%5d watts: \$%.2f (\$%.2f - \$%.2f)\n", $watts, @hyprice[1,0,2]);
}

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
  my($rtimeref, $readingref) = @_;

  my(@rtime) = @{$rtimeref};
  my(@reading) = @{$readingref};

  # if the rtime is possibly bigger than now, ignore
  debug("NOW",@now);
  debug("RTIME",@rtime);
  if ($now[0] <= $rtime[2]) {return;}

  debug("RTIME",@rtime);
  debug("RREAD",@reading);

  # time elapsed between @rtime and @now
  my(@elapse) = ($now[0]-$rtime[2], $now[1]-$rtime[1], $now[2]-$rtime[0]);
  debug("ELAPSE",@elapse);

  # kwh/sec usage between @rtime and @now
  my(@usage2) = (($cur[0]-$reading[2])/$elapse[2],
		 ($cur[1]-$reading[1])/$elapse[1],
		 ($cur[2]-$reading[0])/$elapse[0]);

  # usage in watts
  for $i (@usage2) {$i*=3600000;}

  debug("USAGE2",@usage2);

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

