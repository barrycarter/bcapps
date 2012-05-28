#!/bin/perl

# Computes how much my monthly electric bill might be, under a given
# set of assumptions/conditions [assumes I can read my meter's current value]

# Options:
# -norecord: don't record reading in ~/elecbill.txt

require "/usr/local/lib/bclib.pl";
defaults("norecord=1"); warn "TESTING";

# tiered usage cost (first 450 at .0906, next 450 at .1185, rest at .1284)
# http://www.nmprc.state.nm.us/consumer-relations/company-directory/electric/pnm/forms/form90.pdf is accurate, at least for May 2012
# TODO: this doesn't need to be a constant
@tiers = ([450, 0.0906237], [450, 0.1185101], [+Infinity, 0.1283520]);

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
$maxtime = $now-str2time("$time 08:00:00 MST7MDT");
$mintime = $now-str2time("$time 17:00:00 MST7MDT");

# average kilowatt usage (reading is in kilowatthours)
$max = ($cur-$read)/$mintime*3600;
$min = ($cur-$read)/$maxtime*3600;

debug("MAX/MIN: $max/$min");

# per month (365.2425 days in a year, Gregorian calendar)
($monthmin, $monthmax) = ($min*365.2425/12*24, $max*365.2425/12*24);
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
