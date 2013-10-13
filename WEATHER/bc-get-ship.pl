#!/bin/perl

# does what bc-get-buoy.pl does but for ships (starts out as a copy of
# bc-get-buoy.pl)

# specifically, writes SQL commands to populate madis.db to file where
# bc-query-gobbler.pl will run them

require "/usr/local/lib/bclib.pl";

# columns where data starts (first col = 0)
my(@cols) = (0, 6, 12, 18, 24, 30, 35, 38, 42, 43, 47, 50, 54, 60, 81, 91);

# the data in each columnar block (we ignore some blocks)
my(@names) = ("time", "", "latitude", "longitude", "temperature",
		"dewpoint", "winddir", "windspeed", "", "gust", "", "",
		"pressure", "", "id");
# get data
# TODO: maybe keep older versions briefly to check for errors?
my($out,$err,$res) = cache_command2("curl -o /var/tmp/coolwx.ship.txt http://coolwx.com/buoydata/data/curr/all.html", "age=150");

# split into lines
my(@reports) = split(/\n/, read_file("/var/tmp/coolwx.ship.txt"));

for $i (@reports) {
  # ignore non-data lines
  unless ($i=~/^\d/) {next;}

  # fill hash
  %hash = ();
  $hash{observation} = $i;
  # type is always ship, and elevation is always 0
  $hash{type} = "SHIP";
  $hash{elevation} = "0";

  # somewhat excessive here, but good to know what data is not provided
  for $j ("cloudcover", "events") {$hash{$j} = "NULL";}

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

  # name is effectively id
  $hash{name} = "SHIP-$hash{id}";

  debug("HASH", %hash);
  push(@res, {%hash});

}

@queries = hashlist2sqlite(\@res, "madis");

my($daten) = `date +%Y%m%d.%H%M%S.%N`;
chomp($daten);
my($qfile) = "/var/tmp/querys/$daten-madis-get-ship-$$";
open(A,">$qfile");

# TODO: need to delete old entries from madis and madis_now (maybe)
print A "BEGIN;\n";

for $i (@queries) {
  # REPLACE if needed
  $i=~s/IGNORE/REPLACE/;
  print A "$i;\n";
  # and now for madis_now
  $i=~s/madis/madis_now/;
  print A "$i;\n";
}

print A "COMMIT;\n";
close(A);

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

The list of data that ship report provides that we do NOT use

MaxGst - maximum gust for entire day
PTend - pressure tendency
SeaT - sea temperature
Wvht - wave height
WvPd - not sure

=cut
