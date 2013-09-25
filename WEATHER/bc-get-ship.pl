#!/bin/perl

# does what bc-get-buoy.pl does but for ships (starts out as a copy of
# bc-get-buoy.pl)

# specifically, writes to STDOUT SQL commands to populate weather.db
# (does not actually run them)

require "/usr/local/lib/bclib.pl";

# columns where data starts (first col = 0)
my(@cols) = (0, 6, 12, 18, 24, 30, 35, 38, 42, 43, 47, 50, 54, 60, 81, 91);

# the data in each columnar block (we ignore some blocks)
my(@names) = ("time", "", "latitude", "longitude", "temperature",
		"dewpoint", "winddir", "windspeed", "", "gust", "", "",
		"pressure", "", "id");
# get data
my($out,$err,$res) = cache_command2("curl http://coolwx.com/buoydata/data/curr/all.html", "age=150");

# this file is important enough to keep around
write_file($out, "/var/tmp/coolwx.ship.txt");

# split into lines
my(@reports) = split(/\n/, $out);

for $i (@reports) {
  # ignore non-data lines
  unless ($i=~/^\d/) {next;}

  # fill hash
  %hash = ();
  $hash{observation} = $i;
  # type is always ship
  $hash{type} = "SHIP";

  # somewhat excessive here, but good to know what data is provided
  for $j ("name", "cloudcover", "events") {$hash{$j} = "NULL";}

  # split based on @cols
  for $j (0..$#cols) {
    unless ($names[$j]) {next;}
    my($item) = substr($i, $cols[$j], $cols[$j+1]-$cols[$j]);
    $item=~s/\s//isg;
    $hash{$names[$j]} = $item;
  }

  # TODO: the "tough one" will be day/hour to full timestamp
  $hash{time} = ship2time($hash{time});

  # conversions
  for $j ("temperature", "dewpoint") {
    $hash{$j} = round2(convert($hash{$j},"c","f"),1);
  }

  for $j ("windspeed", "gust") {
    $hash{$j} = round2(convert($hash{$j},"kt","mph"),1);
  }

  $hash{pressure} = round2(convert($hash{pressure},"mb","in"),2);

  debug("HASH", %hash);
  push(@res, {%hash});

}

@queries = hashlist2sqlite(\@res, "weather");

# need to delete old entries from weather and weather_now (maybe)
print "BEGIN;\n";

for $i (@queries) {
  # REPLACE if needed
  $i=~s/IGNORE/REPLACE/;
  print "$i;\n";
  # and now for weather_now
  $i=~s/weather/weather_now/;
  print "$i;\n";
}

print "COMMIT;\n";

# ugly function to round null to null
sub round2 {
  my($num,$digits) = @_;
  # TODO: improve this to deal with other strings
  if ($num eq "NULL") {return "NULL";}
  return sprintf("%0.${digits}f", $num);
}

# kludgey function to convert day/hour to timestamp

sub ship2time {
  my(@now) = gmtime(time());
  # assumed given as "foo/bar";
  my($day,$hour) = split(/\//, $_[0]);
  # today's date (GMT)
  my($today) = strftime("%d", @now);
  # if the given day is in the past (or very near future) it's this month
  if ($day <= $today+1) {
    return strftime("%Y-%m-$day $hour:00:00", @now);
  }

  # otherwise, we're referring to last month (eg, today is the 1st,
  # report says 31st)
  my($year, $month) = split(/\-/, strftime("%Y-%m", @now));
  $month--;
  if ($month < 0) {$year--; $month=12;}

  return "$year-$month-$day $hour:00:00";
}

=item headers

The list of data that buoy report provides that we do NOT use (from
http://www.ndbc.noaa.gov/measdes.shtml)

WVHT - wave height
DPD - Dominant wave period
APD - Average wave period
MWD - The direction from which the [DPD] waves [...] are coming
PTDY - pressure tendency (may add this later)
WTMP - Sea surface temperature (maybe use this later?)
VIS - Station visibility
TIDE - tide

=cut
