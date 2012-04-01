#!/bin/perl

# Gets local weather from wunderground API solely to print on X root window
# runs from cron every 10m
# -show: print out string I send to file

push(@INC,"/usr/local/lib");
require "bclib.pl";

# pull key from private file; you can get your own at api.wunderground.com
require "/home/barrycarter/bc-private.pl";

# below is my personal key
$key = $wunderground{key};

# obtain + JSON parse data (caching solely for testing)
if ($globopts{test}) {$age=300;} else {$age=-1;}
($out, $err, $res) = cache_command("curl http://api.wunderground.com/api/$key/conditions/forecast10day/astronomy/q/KABQ.json", "age=$age");
debug("OUT: $out");
$json = JSON::from_json($out);

# <h>intermediate variables are for sissies!</h>
for $i (@{$json->{forecast}->{simpleforecast}->{forecastday}}) {

  # for now, only want today/tomorrow forecost
  # testing it w/o limits
#  if ($i->{period} > 2) {next;}

  debug("ALPHA: ",$i->{date}->{weekday_short});

  debug("PER: $i->{period}, $i->{date}->{day}");

  # to save screen "real estate", shorten some conditions
  # TODO: do this better
  $i->{conditions}=~s/clear/CLR/isg;
  $i->{conditions}=~s/partly cloudy/PCL/isg;
  $i->{conditions}=~s/chance of a thunderstorm/?TSTORM/isg;

  # want colons to line up!
  $i->{date}->{day}=~s/^(\d)$/0$1/;

  # I want date:conditions/hi/lo/%pop (probability of precipitation)
  push(@forecast, join("", $i->{date}->{weekday_short},$i->{date}->{day},":",$i->{conditions},"/",
	      $i->{high}->{fahrenheit}, "/", $i->{low}{fahrenheit}, "/",
	      $i->{pop},"%"));
}

# now, current: conditions/temp/wc/humid (dewpt)

  $current = join("",
		$json->{current_observation}->{weather}, "/",
		$json->{current_observation}->{temp_f}, "F/",
		$json->{current_observation}->{windchill_f}, "F/",
		$json->{current_observation}->{relative_humidity}, " (",
		$json->{current_observation}->{dewpoint_f}, "F)"
	       );

# time of obs (compacted w/ time first)
$time = $json->{current_observation}->{observation_time};
# get rid of useless string and tz
$time=~s/^last updated on //isg;
# this IS case sensitive
$time=~s/\s*[A-Z]+$//;
$time=~s/^(.*?),\s*(.*?)$/$2, $1/;

# <h>wunderground keeps sunrise/set under moon_phase, interesting</h>

debug(sort keys %{$json->{moon_phase}});

# sun and moon rise/set
debug(unfold($json->{moon_phase}));

# sun line ("0" below is major cheat, since sun always rises between 4-8)
$sun = join("", 
		"S:0", $json->{moon_phase}->{sunrise}->{hour},
		$json->{moon_phase}->{sunrise}->{minute}, "-",
		$json->{moon_phase}->{sunset}->{hour},
		$json->{moon_phase}->{sunset}->{minute}
);

# wind and pressure (dir spdGgust (press))
# treat no gust special
unless ($json->{current_observation}->{wind_gust_mph}) {
  $json->{current_observation}->{wind_gust_mph} = "";
}

$wind = join("", 
	     $json->{current_observation}->{wind_dir}, " ",
	     $json->{current_observation}->{wind_mph}, "G",
	     $json->{current_observation}->{wind_gust_mph}, " (",
	     $json->{current_observation}->{pressure_in}, "in)"
);

# more accurate lunar age, nearest phase
($age, $nphase, $dist) = moon_age();

# lunar phase (these are my own definitions)
# <h>This code brought to you by the Insane School of Hideous Programming</h>
$moonphase =("waxing new", "waxing crescent", "waxing quarter", "waxing gibbous", "waxing full", "waning full", "waning gibbous", "waning quarter", "waning crescent", "waning new")[5*$age/(29.530589/2)];

# using arrows courtesy fly
$moonphase=~s/waxing\s*/\x5e/isg;
$moonphase=~s/waning\s*/\xb7/isg;

# even shorter
$moonphase=~s/(.)(.{4}).*$/$1.uc($2)/iseg;

# age for printing
$mage = sprintf("%0.2f",$age);

# nearest phase for printing (remove all non caps)
$nphase=~s/[^A-Z]//sg;
$dist = sprintf("%0.2f",$dist);
$pphase = "$nphase${dist}d";
$moonphase.=" (${mage}d;$pphase)";

# how many days of forecast to print?
$forecast = join("\n",@forecast[0..6]);

$mrs = moonriseset();

# print in order I want (even if I change mind later)
$str = << "MARK";
$sun
M:$mrs
$moonphase
\@$time
$current
$wind
$forecast
MARK
;

# there really aren't 6 days of forecasts but adding blank lines doesn't hurt

if ($globopts{show}) {print $str;}

# and write to info file
write_file_new($str, "/home/barrycarter/ERR/forecast.inf");

=item moonriseset()

For bc-get-weather, determine today's moon rise and following set
time, with the following rules:

  - If there is a moonrise today, use it.

  - If there is no moonrise today, use yesterday's moonrise, but mark it as so

  - Use the moonset following the moonrise above (not necessarily's today's moonset)

  - If using tomorrow's moonset, mark it as so

NOTE: cheating and using 'now' below, so this function does NOT work
for times other than "now".

=cut

sub moonriseset {
  my($rise,$set);
  my(%hash);
  my($query) = "SELECT event, SUBSTR(REPLACE(TIME(time), ':',''),1,4) AS stime,(strftime('%s',DATE(time))-strftime('%s', DATE('now','localtime')))/86400 AS dist FROM abqastro WHERE event IN ('MR','MS') AND ABS(dist)<=1 ORDER BY time";
  my(@res) = sqlite3hashlist($query, "/home/barrycarter/BCGIT/db/abqastro.db");

  # create hash from results
  for $i (@res) {$hash{$i->{dist}}{$i->{event}} = $i->{stime};}

  # moonrise = today's or yesterday's (marked)
  if ($hash{0}{MR}) {
    $rise = $hash{0}{MR};
  } else {
    $rise = $hash{-1}{MR}."\xb7";
  }

  # if today's moonset is before moonrise (or doesn't exist), use tomorrow's
  if ($hash{0}{MS} > $hash{0}{MR}) {
    $set = $hash{0}{MS}
  } else {
    $set = $hash{1}{MS}."^";
  }

  return "$rise-$set";
}

