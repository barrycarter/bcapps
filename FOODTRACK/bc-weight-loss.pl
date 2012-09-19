#!/bin/perl

# Another program that helps only me (if that), this tracks my weight
# loss and estimates the time until I reach my non-obese and then
# non-overweight goals, starting from when I started tracking calories

require "/usr/local/lib/bclib.pl";

# my weight and when I started tracking calories
$stime = 1347412858;
$startime = stardate($stime-6*3600);
$sweight = 191.8;

# target weights
$t1 = 180;
$t2 = 150;

# I store my current weight in /home/barrycarter/TODAY/yyyymmdd.txt
# files as 'x#%%' where x is my weight in pounds [there used to be
# numbers before the % signs but not any more]

# go backwards through days until finding a weight

for (;;) {
  $stardate = strftime("%Y%m%d",localtime(time()-86400*$i++));
  # last result is the one I want
  $res= `fgrep '#%%' /home/barrycarter/TODAY/$stardate.txt | tail -1`;
  if ($res) {last;}
}

# from $res, extract date and weight
$res=~s/^(\d{6})//;
$date = $1;
$res=~s/([\d\.]+)\#%%//;
$wt = $1;

# convert date to seconds
$secs = datestar("$stardate.$date");

# compute weight loss and targets time (linear)
$tloss = $sweight-$wt;
$days = ($secs-$stime)/86400;

print "Starting weight: $sweight at $startime\nCurrent weight: $wt at $stardate.$date\n\n";

printf("Loss of %0.2f lbs in %0.2f days\nLoss/day: %0.2f lbs\nLoss/week: %0.2f lbs\n\n", $tloss, $days, $tloss/$days, $tloss/$days*7);

# time to targets (linear)
$time1 = ($wt-$t1)/($tloss/$days)*86400+$secs;
$time2 = ($wt-$t2)/($tloss/$days)*86400+$secs;

print strftime("Achieve $t1 lbs (linear): %c\n",localtime($time1));
print strftime("Achieve $t2 lbs (linear): %c\n\n",localtime($time2));

# weight loss (log)
$pctloss = $wt/$sweight;

printf("Loss of %0.2f%% in %0.2f days\nLoss/day: %0.2f%\nLoss/week: %0.2f%\n\n", 100*(1-$pctloss), $days, 100*(1-($pctloss**(1/$days))), 100*(1-($pctloss**(7/$days))));

# time to targets (log)
$ltime1 = (log($wt)-log($t1))/(log($sweight)-log($wt))*$days*86400+$secs;
$ltime2 = (log($wt)-log($t2))/(log($sweight)-log($wt))*$days*86400+$secs;

print strftime("Achieve $t1 lbs (log): %c\n",localtime($ltime1));
print strftime("Achieve $t2 lbs (log): %c\n\n",localtime($ltime2));



