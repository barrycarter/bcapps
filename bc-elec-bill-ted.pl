#!/bin/perl

# Excellently computes how much my monthly electric bill might be,
# using TED device ("the energy detective")

# TODO: there is something seriously wrong w/ the way I am doing this

# --summer: assume summer rates

# TODO:
# measure usage since last reading(s)
# add +-1 minute inaccuracy in reading time (though 8h window sort of covers this)
# allow --time= entries for previous times
# report out of order readings?
# add "median" estimates too?

# NOTE: http://ted.local.lan/api/LiveData.xml may or may not be useful

# TODO: add cost-to-date (not proportional due to tiered billing)

# TODO: the 11:00 reading for hourly may go through 11:59:59, edit program to adjust

# TODO: note that TED not 100% accurate (but close)

# TODO: consider running hourly and putting in cron to see how estimate settles over time and how close it is to actual bill

require "/usr/local/lib/bclib.pl";

# last meter read date in mm/dd/yyyy format <h>(screw Europe!)</h>
my($read) = "12/21/2018";

# TODO: cant get timezone working properly, so setting to -0600 (MDT) for now
# changed to -0700 on 11/22/17 (a bit late)
# back to -0600 on 5/6/18 (also late)
my($tz) = "-0600";

$ENV{"TZ"} = $tz;

# stop reading when we hit old bill

my($stop) = str2time("$read 12:00:00 $tz");

# useful constants/vars
$secspermonth = 365.2425*86400/12; # gregorian

# tiered usage per https://www.pnm.com/documents/396023/396197/schedule_1_a.pdf/d9cfda9e-61a1-4008-ba3c-4152c9dbe7f1

# TODO: should update regularly?

if ($globopts{summer}) {
  @tiers = ([450, 0.0767429], [450, 0.1221238], [+Infinity, 0.1472299]);
} else {
  @tiers = ([450, 0.0767429], [450, 0.1053759], [+Infinity, 0.1198334]);
}

# TODO: tell user if it appears to be summer, but not --summer

# extra per kwh charge for "Fuel Cost Adjustment" and "Renewable Energy Rider"
# only 90% of kwh subject to "Non-Renewable" adjustment

my($fca) = .9*0.0196085 + 0.0054419;

# fixed costs
my($fixed) = 7;

# adding up 5 different taxes

my($taxes) = 1;

for $i (3.249, 2, 5.1250, 1.1875, 1.1875) {$taxes *= (1+$i/100);}

debug("TOTAL TAX RATE: $taxes");

# obtain the latest hourly data to 31 days out, but not more than once an hour

# TODO: since I get bills "late", maybe go out more than 31 days? (2 mos?)

# 1488h = 62d

my($hourly,$herr,$hres) = cache_command2("curl 'http://ted.local.lan/history/rawhourhistory.raw?MTU=0&COUNT=1488&INDEX=0' | tac", "age=3600");

# total kwh cumulation and time
my($kwh, $time);

for $i (split(/\n/, $hourly)) {

  my(@vals) = map($_=ord($_), split(//, decode_base64($i)));

  debug("VALS",@vals);

  # per TED5000-API-R330.pdf (TODO: find full URL)
  # TODO: this is different for minute and second
  my($yr, $mo, $da, $ho) = @vals[0..3];

  # TODO: Y2.1K error possible
  $time = sprintf("20%02d-%02d-%02d %02d:%02d:%02d $tz", @vals[0..3]);

  # TODO: combine w/ above step -- note that 11:00:00 ends at 11:59:59
  $time = str2time($time)+3600;

  # skip if older than previous meter read (assuming noon = imperfect)
  if ($time <= $stop) {next;}

  debug("TIME: $time");

  # TODO: there is a better way to do this
  my($power) = $vals[4] + $vals[5]*256 + $vals[6]*256**2 + $vals[7]*256**3;

  $kwh += $power/1000;

  debug("X: $yr $mo $da $ho $power");
}

debug("KWH: $kwh, THRU: $time");

# and now, the minutes

# to store the latest minute
my($mtime);

my($minutely,$merr,$mres) = cache_command2("curl 'http://ted.local.lan/history/rawminutehistory.raw?MTU=0&COUNT=120&INDEX=0' | tac", "age=120");

debug("MIN: $minutely");

# TODO: redundant code here is bad, format is only slightly different

# TODO: confirm overlap else bad

for $i (split(/\n/, $minutely)) {

  my(@vals) = map($_=ord($_), split(//, decode_base64($i)));

  # per TED5000-API-R330.pdf (TODO: find full URL)
  # TODO: this is different for minute and second
  my($yr, $mo, $da, $ho, $mi) = @vals[0..4];

  # TODO: Y2.1K error possible
  $mtime = sprintf("20%02d-%02d-%02d %02d:%02d:%02d $tz", @vals[0..4]);

  # TODO: combine w/ above step -- note that 11:00:00 ends at 11:00:59
  $mtime = str2time($mtime)+60;

  # if this has already been covered by an hourly reading, ignore it
  if ($mtime < $time) {next;}

  # TODO: there is a better way to do this
  my($power) = $vals[5] + $vals[6]*256 + $vals[7]*256**2 + $vals[8]*256**3;

  $kwh += $power/1000/60;

  debug("X: $yr $mo $da $ho $mi $power $kwh");
}

# TODO: MAYBE add seconds

my($elapsed) = $mtime - $stop;
my($tusage) = $kwh/$elapsed*$secspermonth;

my($cost) = tiered_cost($tusage);

print "Read date: $read 12:00:00 (hour assumed)\n";
printf("Last date: %s (about %d minutes ago)\n", strftime("%m/%d/%Y %H:%M:%S", localtime($mtime)), (time()-$mtime)/60.);
printf("Usage to date: %0.3f\n", $kwh);
printf("Estimted usage month: %0.3f\n", $tusage);
printf("Cost (pre-fees/etc): \$%0.2f\n", $cost);
printf("Cost (total): \$%0.2f\n", ($cost + $fca*$tusage + $fixed)*$taxes);

die "TESTING";

# TODO: make this down to the second or something? (only on request
# due to slowness?)

# look at hours back to 12:00:00 on read date (TODO: assuming fixed
# read date decreases accuracy, but is easier than range calcs I did
# for original version)

my($usage, $edate);

for $i (split(/\n/, $out)) {

  # $x = MTU, a field I don't need
  my($x, $date, $power) = split(/\,/, $i);

  # skip header line
  # TODO: could I do this as tail -n or something, seems ugly
  if ($date=~/"date"/) {next;}

  # if we dont have a end date (= most recent reading), set it here
  unless ($edate) {$edate = $date;}

  # count usage
  $usage += $power;

  # stopping point
  if ($date eq "$read 12:00:00") {last;}

}

# work out cost of $n kilowatthours of electricity, using tiers
# TODO: make this more general and not hardcode variables (or does it already?)

# NOTE: this only returns fuel cost, not fixed/taxes/etc

# TODO: allow @tiers = @stiers as option or when appropriate

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

die "TESTING, DOESNT DO ANYTHING RIGHT NOW";


# yyyy-mm-dd when meter last read, and amount
# TODO: this obviously shouldn't be hardcoded

# probably between 1315 and 1355 based on my pictorial record,
# assuming rounding to nearest number

($time,$read) = ("2014-07-22", "79606");

# same month last year (as target)
# $lastyearcost = "103.15";
# $lastyearusage = "821";

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

  # push on list of measurements (couldn't do with more refs, alas)
  push(@measures, [@rtime, @reading]);
}

close(A);
close(B);

# we want the last reading first (yes, I could've used unshift above!)
# @measures = reverse(@measures);

# debug(unfold(@measures));

for $i (0..$#measures-1) {
  # TODO: redundant code, blech
  @rtime1 = @{$measures[$i]}[0..2];
  @read1 = @{$measures[$i]}[3..5];
  @rtime2 = @{$measures[$i+1]}[0..2];
  @read2 = @{$measures[$i+1]}[3..5];

  # time between the two readings
  # <h>Today on how NOT to name your variables...</h>
  @timediff = ($rtime1[0]-$rtime2[2], $rtime1[1]-$rtime2[1], 
	       $rtime1[2]-$rtime2[0]);

  # and usage
  @usagediff = ($read1[0]-$read2[2], $read1[1]-$read2[1], $read1[2]-$read2[0]);

  # and wattage
  @wattage = ($usagediff[2]/$timediff[0], $usagediff[1]/$timediff[1],
	      $usagediff[0]/$timediff[2]);

  # above is kwh/s, so converting
  for $j (@wattage) {$j*=3600000;}

  debug("RTIME",@rtime1,"x",@rtime2);
  debug("READ",@read1,"x",@read2);
  debug("TIMEDIFF",@timediff);
  debug("USDIFF",@usagediff);
  debug("WATTAGE",@wattage);

  # and print (no ranges here, but ok w/ that)
  printf("Watts (%.2f - %.2f days ago [%.2f d]): %d (%d - %d)\n",
	 ($now-$rtime2[1])/86400, ($now-$rtime1[1])/86400,
	 ($rtime1[1]-$rtime2[1])/86400, @wattage[1,2,0]);
}

print "\n";

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

