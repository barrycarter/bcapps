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
 "#STN:id",
 "WDIR:winddir",
 "WSPD:windspeed:mps:mph:1",
 "GST:gust:mps:mph:1",
 "ATMP:temperature:c:f:1",
 "DEWP:dewpoint:c:f:1",
 "PRES:pressure:hpa:in:2"
);

# TODO: check for id conflict

# get data, split into lines
# TODO: error check here and stop if $out is too small, $err exists,
# $res is non-zero or something
$url = "http://www.ndbc.noaa.gov/data/latest_obs/latest_obs.txt";
my($out,$err,$res) = cache_command2("curl $url", "age=150");
# this file is important enough to keep around
write_file($out, "/var/tmp/noaa.buoy.txt");
map(push(@res, [split(/\s+/,$_)]), split(/\n/,$out));
($hlref) = arraywheaders2hashlist(\@res);

for $i (@{$hlref}) {
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

  # special cases
  # TODO: we don't get the entire observation and thats actually kind of bad

  $hash{type} = "BUOY-PARSED";
  $hash{source} = $url;

  $hash{time} = "$i->{YYYY}-$i->{MM}-$i->{DD} $->{hh}:$i->{mm}:00";
  # sea level
  $hash{elevation} = 0;
  $hash{name} = "BUOY-$hash{id}";

  push(@hashlist,{%hash});
}

@queries = hashlist2sqlite(\@res, "madis");
my($daten) = `date +%Y%m%d.%H%M%S.%N`;
chomp($daten);
my($qfile) = "/var/tmp/querys/$daten-madis-get-buoy-$$";
open(A,">$qfile");

# need to delete old entries from madis and madis_now (maybe)
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
