#!/bin/perl

# Another program that helps only me (if that), this tracks my weight
# loss and estimates the time until I reach my non-obese and then
# non-overweight goals, starting from when I started tracking calories

require "/usr/local/lib/bclib.pl";

# plot using gnuplot
open(A,">/tmp/bwl.txt");

# my weight and when I started tracking calories
$stime = 1347412858;
$startime = stardate($stime-6*3600);
$sweight = 191.8;

# some useful calculated values
$now = time();

# obtain all weights and do linear regression (experimental for now)
%weights = obtain_weights($stime);

# to make life easier, converting times to days since $stime
for $i (sort keys %weights) {
  my($days) = ($i-$stime)/86400;
  my($days2) = ($i-$now)/86400;
  print A "$days2 $weights{$i}\n";
  push(@x, $days);
  push(@y, $weights{$i});
  push(@z,log($weights{$i}));
}

close(A);

# the regression coefficients for standard and log regression
($b,$m) = linear_regression(\@x,\@y);
# <h>I've always wanted to name a variable $blog for a good reason!</h>
($blog,$mlog) = linear_regression(\@x,\@z);

# plot log/linear regression (to now, not just to last reading)
$daysago = ($stime-$now)/86400;
$linweight = $b - $m*$daysago;
# this should be an exponential curve, but close to linear for now
$logweight = exp($blog - $mlog*$daysago);
write_file("$daysago $b\n0 $linweight\n","/tmp/bwl2.txt");
write_file("$daysago $b\n0 $logweight\n","/tmp/bwl3.txt");

# and the straight line (very inaccurate) estimation
# TODO: getting loss in sea of variables
$mostrecent = $x[-1]-($now-$stime)/86400;
write_file("$daysago $y[0]\n$mostrecent $y[-1]\n", "/tmp/bwl4.txt");
# same for log (first two points)
write_file("$daysago $y[0]\n$mostrecent $y[-1]\n", "/tmp/bwl5.txt");

debug("DAYSAGO: $daysago, LINWT: $linweight");

# target weights (borders for obese, overweight, normal, and severely underweight) [added midpoints 30 Sep 2012 JFF]
@t=(180,165,150,135,120,105,90);

# I store my current weight in /home/barrycarter/TODAY/yyyymmdd.txt
# files as 'x#%%' where x is my weight in pounds [there used to be
# numbers before the % signs but not any more]

# go backwards through days until finding a weight
for ($i=0;;) {
  $stardate = strftime("%Y%m%d",localtime($now-86400*$i++));
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

# TODO: use linear regression, not first/last points?

# compute weight loss and targets time (linear)
$tloss = $sweight-$wt;
$days = ($secs-$stime)/86400;

print "Starting weight: $sweight at $startime\nCurrent weight: $wt at $stardate.$date\n\n";

printf("Loss of %0.2f lbs in %0.2f days (%0.2f lb per day, %0.2f lb per week)\n", $tloss, $days, $tloss/$days, $tloss/$days*7);

printf("Linear Regression: %0.2f + %0.4f*t = %0.2f\n\n", $b, $m, $b+$m*$days);

# time to targets (linear)
for $i (0..$#t) {
  $time[$i] = ($wt-$t[$i])/($tloss/$days)*86400+$secs;
  # rtime = linear w regression
  $rtime[$i] = ($t[$i]-$b)/$m*86400+$stime;

  # and plotting
  $daysfromnow = ($rtime[$i]-$now)/86400;
  append_file("$daysfromnow $t[$i]\n", "/tmp/bwl2.txt");

  $daysfromnow = ($time[$i]-$now)/86400;
  append_file("$daysfromnow $t[$i]\n", "/tmp/bwl4.txt");

  print strftime("Achieve $t[$i] lbs (linear): %c\n",localtime($time[$i]));
  print strftime("Achieve $t[$i] lbs (linreg): %c\n",localtime($rtime[$i]));
  print "\n";
}

# weight loss (log)
$pctloss = $wt/$sweight;

printf("Loss of %0.2f%% in %0.2f days (%0.2f%% per day, %0.2f%% per week)\n", 100*(1-$pctloss), $days, 100*(1-($pctloss**(1/$days))), 100*(1-($pctloss**(7/$days))));

printf("Log regression: %0.2f*(%0.4f)^t = %0.2f\n\n", exp($blog), exp($mlog), exp($blog+$mlog*$days));

# time to targets (log)
for $i (0..$#t) {
  $ltime[$i] = (log($wt)-log($t[$i]))/(log($sweight)-log($wt))*$days*86400+$secs;
  # regressed
  $lrtime[$i] = (log($t[$i])-$blog)/$mlog*86400+$stime;

  # TODO: appending here is silly, should just keep file open longer
  # and plotting
  $daysfromnow = ($lrtime[$i]-$now)/86400;
  append_file("$daysfromnow $t[$i]\n", "/tmp/bwl3.txt");

  $daysfromnow = ($ltime[$i]-$now)/86400;
  append_file("$daysfromnow $t[$i]\n", "/tmp/bwl5.txt");

  print strftime("Achieve $t[$i] lbs (strlog): %c\n",localtime($ltime[$i]));
  print strftime("Achieve $t[$i] lbs (logreg): %c\n\n",localtime($lrtime[$i]));
}

open(B,">/tmp/bwl.plt");
print B << "MARK";
set style line 1 lc rgb "blue"
set style line 2 lc rgb "black"
set style line 3 lc rgb "purple"
set style line 4 lc rgb "green"
set xlabel "Days ago"
set ylabel "Weight"
plot "/tmp/bwl.txt" title "Weight" with linespoints, \\
"/tmp/bwl2.txt" title "LinReg" with linespoints ls 1, \\
"/tmp/bwl3.txt" title "LogReg" with linespoints ls 2, \\
"/tmp/bwl4.txt" title "Linear" with linespoints ls 3, \\
"/tmp/bwl5.txt" title "Log" with linespoints ls 4
MARK
;

close(B);

system("gnuplot -persist /tmp/bwl.plt");
