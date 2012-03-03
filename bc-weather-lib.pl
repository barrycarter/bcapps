# Am I creating too many libs?

# TODO: standardize units to match weather.sql

# weather abbreviations

our(%ABBREV) = ("BC" => "Patches", "BL" => "Blowing", "DR" => "Low
Drifting", "FZ" => "Supercooled/freezing", "MI" => "Shallow", "PR" =>
"Partial", "SH" => "Showers", "TS" => "Thunderstorm", "BR" => "Mist",
"DS" => "Dust Storm", "DU" => "Widespread Dust", "DZ" => "Drizzle",
"FC" => "Funnel Cloud", "FG" => "Fog", "FU" => "Smoke", "GR" =>
"Hail", "GS" => "Small Hail/Snow Pellets", "HZ" => "Haze", "IC" =>
"Ice Crystals", "PL" => "Ice Pellets", "PO" => "Dust/Sand Whirls",
"PY" => "Spray", "RA" => "Rain", "SA" => "Sand", "SG" => "Snow
Grains", "SN" => "Snow", "SQ" => "Squall", "SS" => "Sandstorm", "UP"
=> "Unknown Precipitation (Automated Observations)", "VA" => "Volcanic
Ash" );

# TODO: bad idea?
for $i (keys %ABBREV) {$ABBREV{$i} = lc($ABBREV{$i});}

=item day2time($day, $hour)

Given day of month $day and hour $hour, figure out month and year.

TODO: this is a very kludgey function, solely for weather report oddness

=cut

sub day2time {
  my($day, $hour) = @_;
  my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time());

  # tweak return values
  $year+=1900;
  $mon++;
  if ($mon==13) {$year++; $mon=1;}

  # timestamp for this day of this month
  my($thismo) = str2time("$year-$mon-$day UTC");

  # 15 days either way, though this will never happen
  if (($thismo - time()) < 86400*15) {return($mon,$year);}

  # last month
  $mon--;
  if ($mon<=0) {$year--; $mon=12;}

  return($mon,$year);
}

=item th2dp($t, $h)

Given temperature $t in Farenheit and humidity $h (between 0 and 100),
return dewpoint in Farenheit.

This is a Farenheit-ed version of the inverse of the first formula
given in metaf2xml

=cut

sub th2dp {
  my($t,$h) = @_;
  debug("TH2DP($t,$h)");
  if (length($t)==0 || $t eq "NULL" || $h eq "NULL" || length($h)==0) {
    return "NULL";
  }

  $h/=100;
  return (2280.52*$t + (48365.8 + 122.179*$t)*log($h))/
    (2280.52 + (-122.179 - 0.308642*$t)*log($h));
}

=item recent_weather($options)

Obtain recent weather from http://weather.aero/dataserver_current/cache/metars.cache.csv.gz and return as list of hashes

$options currently unused

=cut

sub recent_weather {
  my($options) = @_;
  my(@headers);
  my(@hashes);
  my($res) = cache_command("curl http://weather.aero/dataserver_current/cache/metars.cache.csv.gz | gunzip | tail -n +6", "age=150");

  # HACK: csv() does not handle ",," well
  while ($res=~s/,,/, ,/isg) {}

  # this file is important enough to keep around
  write_file($res, "/var/tmp/weather.aero.metars.txt");

  my(@res) = split(/\n/, $res);

  # header line
  @headers = csv(shift(@res));

  # go through data
  for $i (@res) {
    my(@line) = csv($i);
    my(%hash) = ();
    for $j (0..$#headers) {
      # remove the space I added above (sigh)
      $line[$j]=~s/^\s*$//isg;
      $hash{$headers[$j]} = $line[$j];
  }
    push(@hashes, {%hash});
  }

  return @hashes;
}

=item weather_hash(\%hash)

Given a hash of weather data (converted to XML via metaf2xml and
metafsrc2raw, and converted to a hash using XML::Simple), return a hash
to populate the table described in weather.sql

Unavailable fields are returned as "NULL" (the 4 letter string), since
handling NULL as a quantity is difficult between Perl and SQLite3

=cut

sub weather_hash {
  my($hashref) = @_;
  my(%hash) = %{$hashref};
  my(%rethash);

  # this must occur before unburying buoy data below
  # entire observation
  $rethash{observation} = coalesce([$hash{s}]);

  # type of observation (this may leave 'type' blank if neither BUOY nor SHIP)
  if ($rethash{observation}=~/^ZZYY/) {
    $rethash{type} = "BUOY";
  } elsif ($rethash{observation}=~/^(BB|AA)XX/) {
    $rethash{type} = "SHIP";
  } elsif ($hash{synop}) {
    $rethash{type} = "SYNOP";
  } else {
    $rethash{type} = "METAR";
  }

  # BUOYS bury sections one level deep; this fixes
  for $i (sort keys %{$hash{buoy_section1}}) {
    $hash{$i} = $hash{buoy_section1}{$i};
  }

  # time
  # TODO: this will become an issue w/ different formats
  my($hour) = coalesce([$hash{exactObsTime}{timeAt}{hour}{v},
		       $hash{obsTime}{timeAt}{hour}{v}]);

  my($minute) = coalesce([$hash{exactObsTime}{timeAt}{minute}{v},
		       $hash{obsTime}{timeAt}{minute}{v}]);


  my($day) = coalesce([$hash{obsTime}{timeAt}{day}{v}]);

  $rethash{time} = strftime("%Y-%m-%d %H:%M", gmtime(dahrmi2time($day, $hour, $minute)));

  # station id
  $rethash{id} = coalesce([$hash{obsStationId}{id}{v}, $hash{callSign}{id}{v},
			 $hash{buoyId}{id}{v}]);

  # below now works for fixed stations too
  $rethash{latitude} = coalesce([$hash{stationPosition}{lat}{v}, $lat{$rethash{id}}]);
  $rethash{longitude} = coalesce([$hash{stationPosition}{lon}{v}, $lon{$rethash{id}}]);

  $rethash{cloudcover} = coalesce([$hash{totalCloudCover}{oktas}{v}]);

  debug("ID: $rethash{id}, $rethash{latitude}, $rethash{longitude}");
  # temperature is in this field, unless NA (converted to F)
  $rethash{temperature} = coalesce([
   convert_uv($hash{temperature}{air}{temp})]);

  # humidity (just in case we need it below, not part of report)
  my($humidity) = coalesce([$hash{temperature}{relHumid1}{v}]);

  # dewpoint
  $rethash{dewpoint} = coalesce([
   convert_uv($hash{temperature}{dewpoint}{temp}),
   th2dp($rethash{temperature}, $humidity)
]);

  # pressure, in inches (not sure third one is ever used but...)
  $rethash{pressure} = coalesce([
   $hash{QNH}{inHg}{v},
   convert($hash{QNH}{hPa}{v}, "hpa", "in"),
   $hash{SLP}{inHg}{v},
   convert($hash{SLP}{hPa}{v}, "hpa", "in")]);

  # wind direction, speed, gust
  $rethash{winddir} = coalesce([$hash{sfcWind}{wind}{dir}{v}]);
  $rethash{windspeed} = coalesce([
   convert_uv($hash{sfcWind}{wind}{speed})]);
  $rethash{gust} = coalesce([
   convert_uv($hash{synop_section3}{highestGust}{wind}{speed})]);

  # TODO: unit checks across the board!
  # TODO: be suspicious of too many nulls in a given column

  return %rethash;
}


# TODO: this needs to be a real function, since weather_hash() uses it.

# given a hash with units u and value v, return value in "canonical"
# form (subroutine is specific to a given program, not generic)

sub convert_uv {
  my($hashref) = @_;

  # no data? if v is not empty, worry
  if ($hashref->{u} eq "") {
    if ($hashref->{v} eq "") {
      return "NULL";
    } else {
      return "ERR";
    }
  }

  # c to f
  if ($hashref->{u} eq "C") {return convert($hashref->{v}, "c", "f");}
  # mps to mph
  if ($hashref->{u} eq "MPS") {return convert($hashref->{v}, "mps", "mph");}
  # knots to mph
  if ($hashref->{u} eq "KT") {return convert($hashref->{v}, "kt", "mph");}

  debug("CONVERT_UV DISLIKES: $hashref->{u}, $hashref->{v}");

  return "ERR";
}

=item dahrmi2time($da, $hr, $mi, $time=time())

Given day $da, hour $hr, minute $mi, return Unix timestamp nearest to $time

NOTE: without the $time argument, I could use things like:

 date +%s -d 'last month'
 date +%s -d 'next month'

=cut

sub dahrmi2time {
  my($da, $hr, $mi, $time) = @_;
  unless ($time) {$time=time()};

  # if minute null, assume 0
  if ($mi eq "NULL") {$mi=0;}

  # obtain/tweak values for time to match
  my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($time);
  $year+=1900;
  $mon++;
  if ($mon==13) {$year++; $mon=1;}

  # timestamp for da/hr/mi "this" month
  my($thismo) = str2time("$year-$mon-$da $hr:$mi UTC");

  # and last month
  $mon--;
  if ($mon<=0) {$year--; $mon=12;}
  my($lastmo) = str2time("$year-$mon-$da $hr:$mi UTC");

  # and compare
  if (abs($lastmo-$time) < abs($thismo-$time)) {
    return $lastmo;
  }

  return $thismo;
}

=item recent_weather_buoy($options)

Obtain recent weather from
http://www.ndbc.noaa.gov/data/latest_obs/latest_obs.txt and return as
list of hashes that are compatible with newmetar.metar table

$options currently unused

TODO: should I create a separate buoy-specific db table and union or something?

=cut

sub recent_weather_buoy {
  my($options) = @_;
  my(@res);

  # get data, split into lines
  my($out) = cache_command("curl http://www.ndbc.noaa.gov/data/latest_obs/latest_obs.txt", "age=150");

  # this file is important enough to keep around
  write_file($out, "/var/tmp/noaa.buoy.txt");

  # HACK: csv() does not handle ",," well
  $out=~s/,,/, ,/isg;

  my(@reports) = split(/\n/, $out);

  # header line (remove '#' at start of line)
  $headers = shift(@reports);
  $headers=~s/^\#//isg;
  @headers = split(/\s+/, $headers);

  # useless line (gives units of measurements)
  shift(@reports);

  for $i (@reports) {

    # set hash directly from data
    my(%hash) = ();
    my(%dbhash) = ();
    @fields = split(/\s+/, $i);
    for $j (0..$#headers) {
      # remove the space I added above (sigh)
      $fields[$j]=~s/^\s*$//isg;
      $hash{$headers[$j]} = $fields[$j];
    }
    # sqlite3 case insensitivity requires below
    $hash{minute} = $hash{mm}; delete $hash{mm};

    # NOTE: The dbhash code below is NOT currently used; I've decided
    # to go with a separate table for buoy data
    # create hash that we'll use for insert
    $dbhash{station_id} = $hash{STN};
    $dbhash{observation_time} = "$hash{YYYY}-$hash{MM}-$hash{DD}T$hash{hh}:$hash{mm}:00Z";
    $dbhash{latitude} = $hash{LAT};
    $dbhash{longitude} = $hash{LON};
    # ATM = air temperature <h>, not automated teller machine!</h>
    $dbhash{temp_c} = $hash{ATM};
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

    # As above, %dbhash is unused
    push(@res, {%hash});
    }

return @res;
}

=item wc($t, $w)

Given the current temperature $t in Farenheit and the current
windspeed $w in miles-per-hour, return the windchill temperature in
Farenheit

=cut

sub wc {
  my($t,$w)=@_;
  if ($w<3 || $t>=50) {return($t);}
  return(35.74+0.6215*$t-(35.75-0.4275*$t)*$w**.16);
}

=item recent_weather_ship($options)

Obtain recent ship weather from
http://coolwx.com/buoydata/data/curr/all.html and return as list of
hashes that are compatible with newmetar.metar table $options
currently unused

=cut

sub recent_weather_ship {
  my($options) = @_;
  my(@res);
  my(%hash);

  # columns where data starts (first col = 0)
  # should write a general column parsing routine, but too lazy
  my(@cols) = (0, 6, 12, 18, 25, 30, 35, 42, 47, 54, 60, 81, 91);
  # trying to make these match metar table to extent possible
  my(@names) = ("day", "", "latitude", "longitude", "temp_c",
		"dewpoint_c", "wind", "gust", "maxgst",
		"sea_level_pressure_mb", "", "station_id");

  # get data, keep
  my($out) = cache_command("curl -o /var/tmp/coolwx.ship.txt http://coolwx.com/buoydata/data/curr/all.html", "age=150");

  for $i (split(/\n/, read_file("/var/tmp/coolwx.ship.txt"))) {
    # ignore non-data lines
    unless ($i=~/^\d/) {next;}

    # get fields
    for $j (0..$#cols) {
      my($item) = substr($i, $cols[$j], $cols[$j+1]-$cols[$j]);
      $item=~s/\s//isg;
      $hash{$names[$j]} = $item;
      debug("$names[$j] -> $item");
    }

    push(@res, {%hash});
  }
  
  return @res;
}



# <h>return beauty;</h>
true;
