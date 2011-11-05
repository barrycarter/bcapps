#!/bin/perl

# bc-voronoi-temperature (not to be confused w bc-temperature-voronoi)
# is a clone of bc-delaunay-temperature, but using voronoi instead of
# delaunay

# NOTE: this program starts off as an exact copy of delaunay

push(@INC,"/home/barrycarter/BCGIT", "/usr/local/bin/");
require "bclib.pl";
require "bc-weather-lib.pl";
require "bc-kml-lib.pl";

# all work in temporary-but-permanent directory
chdir("/var/tmp/bcvtp");

# obtain current weather including buoys
# @w = recent_weather();
warn "TESTING; just buoys";

@w2 = recent_weather_buoy();

# convert buoy hash to metar-style hash
for $i (@w2) {
  %hash = %{$i};
  %dbhash = ();

  # below stolen from bc-weather-lib where its unused; should make this a function
  $dbhash{station_id} = $hash{STN};
  $dbhash{observation_time} = "$hash{YYYY}-$hash{MM}-$hash{DD}T$hash{hh}:$hash{mm}:00Z";
  $dbhash{latitude} = $hash{LAT};
  $dbhash{longitude} = $hash{LON};
  # ATMP = air temperature
  $dbhash{temp_c} = $hash{ATMP};
  # <h>DEWP? There it is!</h>
  $dbhash{dewpoint_c} = $hash{DEWP};
  $dbhash{wind_dir_degrees} = $hash{WDIR};
  $dbhash{wind_speed_kt} = convert($hash{WSPD}, "mps", "kt");
  $dbhash{wind_gust_kt} = convert($hash{GST}, "mps", "kt");
  
  # buoys are at sea level, so SLP = actual pressure
  $dbhash{altim_in_hg} = convert($hash{PRES}, "hpa", "in");
  $dbhash{sea_level_pressure} = convert($hash{PRES}, "hpa", "in");
  # millibars and hPa are identical, no need to convert
  $dbhash{three_hr_pressure_tendency_mb} = $hash{PTDY};

  push(@w, {%dbhash});

}

for $i (@w) {
  %hash = %{$i};

  debug("BETA",%hash);

  # confirm numeric
  unless ($hash{latitude}=~/^[0-9\-\.]+$/ && $hash{longitude}=~/^[0-9\-\.]+$/) {
    warn("BAD DATA:");
    debug("HASH", %hash);
    next;
  }

  # no temperature? no go!
  if ($hash{temp_c} eq "NULL" || $hash{temp_c} eq "") {
    debug("$hash{station_id} has no temperature");
    next;
  }

  # TODO: mercator version?
  # fields for voronoi_map()
  $hash{x} = $hash{longitude};
  $hash{y} = $hash{latitude};
  $hash{id} = $hash{station_id};
  $f= $hash{temp_c}*1.8+32;
  $hue = 5/6-($f/100)*5/6;
  $hash{color} = hsv2rgb($hue, 1, 1, "kml=1&opacity=80");

  # pretty print data
  $f = round($f,1);
  # TODO: change this, maybe
  $hash{label} = "$hash{station_id}: ${f}F at $hash{observation_time}";


  push(@wok, {%hash});

}

$res = voronoi_map(\@wok);
debug("RES: $res");

# this file is generated on a different machine, so copy file over
system("rsync $res root\@data.barrycarter.info:/sites/DATA/current-voronoi.kmz");

# sleep 2.5 minutes and call myself again
sleep(150);
exec($0);

# TODO: reinstate this code for Voronoi maps
# update time in various timezones (silly!)

=item comment

$now = time(); # just so we don't get second slippage

for $i ("UTC", "EST5EDT", "MST7MDT", "Japan") {
  $ENV{TZ} = $i;
  push(@desc, strftime("%c", localtime($now)));
}

$desc = join("<br>\n", @desc);

open(A,">file3.kml");

# special marker below is at 4 Corners + indicates update time
print A << "MARK";
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>

<Placemark>
<name>Last updated:</name>
<description>
<![CDATA[
<font size=-1>
$desc
</font>
]]>
</description>
<Point>
<coordinates>-109,37</coordinates>
</Point>
</Placemark>

MARK
;

print A join("\n", @kml);
print A "\n</Document></kml>\n";
close(A);

system("zip file3.kmz file3.kml");

=cut

