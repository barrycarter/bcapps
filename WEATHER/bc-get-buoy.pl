#!/bin/perl

# does pretty much what recent_weather_buoy() does, but tries to
# comply to weather2.sql and do more error checking

# specifically, writes to STDOUT SQL commands to populate madis.db
# (does not actually run them)

require "/usr/local/lib/bclib.pl";

# see bc-get-metar.pl to see what this does
@convert = (
 "LAT:latitude",
 "LON:longitude",
 "STN:id",
 "WDIR:winddir",
 "WSPD:windspeed:mps:mph:1",
 "GST:gust:mps:mph:1",
 "ATMP:temperature:c:f:1",
 "DEWP:dewpoint:c:f:1"
);

# TODO: check for id conflict

# get data, split into lines
# TODO: error check here and stop if $out is too small, $err exists,
# $res is non-zero or something
my($out,$err,$res) = cache_command2("curl http://www.ndbc.noaa.gov/data/latest_obs/latest_obs.txt", "age=150");
# this file is important enough to keep around
write_file($out, "/var/tmp/noaa.buoy.txt");
debug("OUT: $out");

map(push(@res, [split(/\s+/,$_)]), split(/\n/,$out));
($hlref) = arraywheaders2hashlist(\@res);

for $i (@{$hlref}) {
  debug("I: $i");

  for $j (sort keys %{$i}) {
    debug("BETA: $j");
  }

  # the resulting hash
  my(%hash) = ();

  for $j (@convert) {
    my($f1,$f2,$u1,$u2,$r) = split(/:/,$j);
    # start by copying file field to hash field
    $hash{$f2} = $i->{$f1};
    # unit conversion
    if ($u1 && $u2) {$hash{$f2} = convert($hash{$f2},$u1,$u2);}
    # rounding
    if (length($r)) {$hash{$f2} = round2($hash{$f2},$r);}
  }

  debug("HASH",%hash);
}

die "TESTING";


# find first nonblank line
do {$headers = shift(@reports)} until $headers;
# header line (remove '#' at start of line)
$headers=~s/^\#//isg;
@headers = split(/\s+/, $headers);
# useless line (gives units of measurements)
shift(@reports);

# go through reports
for $i (@reports) {

  # the whole report
  my(%dbhash) = ();
  $dbhash{observation} = $i;

  # set hash directly from data
  my(%hash) = ();
  @fields = split(/\s+/, $i);


  # set hash from headers
  for $j (0..$#headers) {
    # remove the space I added above (sigh)
    $fields[$j]=~s/^\s*$//isg;
    $hash{$headers[$j]} = $fields[$j];
  }

  # all BUOY data here and elevation is 0
  $dbhash{type} = "BUOY";
  $dbhash{elevation} = 0;

  # somewhat excessive here, but good to know what data is provided
  for $j ("name", "cloudcover", "events") {$dbhash{$j} = "NULL";}

  # the date (uses up many fields)
  $dbhash{time} = "$hash{YYYY}-$hash{MM}-$hash{DD} $hash{hh}:$hash{mm}:00";

  # pressure
  $dbhash{pressure} = round2(convert($hash{PRES},"hpa","in"),2);

  # set dbhash values that convert over
  for $j (keys %convert) {$dbhash{$convert{$j}} = $hash{$j};}

  # similar, but convert m/s to mph (accurate to nearest 10th only)
  for $j (keys %convertms) {
    $dbhash{$convertms{$j}} = round2(convert($hash{$j},"mps","mph"),1);
  }

  # similar, but convert C to F (to nearest 10th only)
  for $j (keys %convertcf) {
    $dbhash{$convertcf{$j}} = round2(convert($hash{$j},"c","f"),1);
  }

  # push this hash to results
  push(@res, {%dbhash});
}

@queries = hashlist2sqlite(\@res, "madis");

# need to delete old entries from madis and madis_now (maybe)
print "BEGIN;\n";

for $i (@queries) {
  # REPLACE if needed
  $i=~s/IGNORE/REPLACE/;
  print "$i;\n";
  # and now for madis_now
  $i=~s/madis/madis_now/;
  print "$i;\n";
}

print "COMMIT;\n";

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
