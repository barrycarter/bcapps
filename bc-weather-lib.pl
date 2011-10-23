# Am I creating too many libs?

# TODO: standardize units to match weather.sql

# Reference documents:
# ftp://daac.ornl.gov/data/lba/physical_climate/SCAR-B/comp/WMO306vol-I-1PartA.pdf

=item parse_ship($report)

Parses a SHIP report from
http://weather.noaa.gov/pub/SL.us008001/DF.an/DC.sfmar/DS.ships/,
based on www.nws.noaa.gov/om/marine/handbk1.pdf, returning a hash of data.

Note: SHIP reports may have multiple lines, but $report should be a
single line

=cut

sub parse_ship {
  my($report) = @_;
  my(%rethash) = ();

  # the whole thing
  $rethash{observation} = $report;

  # we ignore section 2 entirely
  $report=~s/\s+222\d\d.*$//isg;

  # TODO: it's probably ok to change / to 0 [maybe not]
  $report=~s%/%0%isg;

  # split report into chunks
  my(@chunks) = split(/\s+/, $report);

  # the first few elements are fixed
  my($id, $datetime, $lat, $lon, $useless, $wind) = @chunks;

  # $datetime is in DDHHx format, where x indicates wind speed measure type
  # TODO: convert date/hour to Unix time or at least find month/year
  unless ($datetime=~/^(\d{2})(\d{2})([0134])$/) {return "BADTIME: $datetime";}
  my($date, $hour) = ($1, $2);
  my($wsm) = $3;
  my($month, $year) = day2time($date);
  $rethash{time} = "$year-$month-$date $hour:00:00";

  # $lat is 99xxx where xxx = lat/10
  unless ($lat=~/^99(\d{3})$/) {return "BADLAT: $lat";}
  $lat = $1/10;

  # first digit/char in $longitude indicates quadrant, rest is lon/10
  unless ($lon=~/^(1|3|5|7)(\d{4})$/) {return "BADLON: $lon"}
  $lon = $2/10;
  my($quad) = $1;

  # wind is Nddff where N=cloud cover/8, dd=direction, ff=speed
  unless ($wind=~/^(\d)(\d{2})(\d{2})$/) {return "BADWIND: $wind";}
  ($rethash{cloudcover}, $rethash{winddir}, $rethash{windspeed}) = ($1,$2*10,$3);
  # if wind speed was given in m/s, convert to knots
  if ($wsm==0 || $wsm==1) {$rethash{windspeed} *= 1.9438445;}

  # and always convert knots to mph
  $rethash{windspeed} *= 0.8689766;

  # correct latitude/longitude for quadrant
  if ($quadrant==5 || $quadrant==7) {$lon*=-1;}
  if ($quadrant==3 || $quadrant==5) {$lat*=-1;}

  # and put into results
  $rethash{type} = "SHIP";
  $rethash{id} = $id;
  $rethash{latitude} = $lat;
  $rethash{longitude} = $lon;

  # rest of report is optional
  for $i (@chunks) {
    # only care about temperature/pressure
    unless ($i=~/^[124]\d{4}$/) {next;}

    # temperature (1xttt, x=sign, ttt=temperature*10 Celsius)
    if ($i=~/^1(0|1)(\d{3})/) {
      $rethash{temperature} = $2/10*(0.5<=>$1);
      # convert to F
      $rethash{temperature} = $rethash{temperature}*1.8+32;
      next;
    }

    # dewpoint (2xttt, same convention as temperature)
    if ($i=~/^2(0|1)(\d{3})/) {
      $rethash{dewpoint} = $2/10*(0.5<=>$1);
      # convert to F
      $rethash{dewpoint} = $rethash{dewpoint}*1.8+32;
      next;
    }

    # pressure (4xxxx) where xxxx is hectopascals*10 last four digits
    if ($i=~/4(\d{4})$/) {
      $rethash{pressure} = ($1+($1<5000?10000:0))/10;
      # convert to inches of mercury
      $rethash{pressure} /= 33.8638;
      next;
    }

  }
  return %rethash;

}

=item parse_buoy($report)

Parses a BUOY report (in FM18 format) from
http://weather.noaa.gov/pub/SL.us008001/DF.an/DC.sfmar/DS.dbuoy/,
based on
http://www.wmo.int/pages/prog/www/WMOCodes/Manual/Volume-I-selection/Sel2.pdf,
returning a hash of data.

Note: reports may have multiple lines, but $report should be a single line

=cut

sub parse_buoy {
  my($report) = @_;
  my(%rethash) = ();

  # TODO: it's probably ok to change / to 0
  $report=~s%/%0%isg;

  # we ignore sections 2+ entirely
  $report=~s/\s+222\d\d.*$//isg;

  # split report into chunks
  my(@chunks) = split(/\s+/, $report);

  debug("CHUNKS",@chunks);

  # the first few elements are fixed
  # TODO: this format differs slightly from PDF file, ponder
  my($id, $date, $time, $lat, $lon, $quality) = @chunks;

  # date is in DDMMY format
  unless ($date=~/^(\d{2})(\d{2})(\d)$/) {return "BADDATE: $date";}
  # TODO: don't hardcode 2010 below
  my($year, $month, $day) = (2010+$3, $2, $1);

  # time in HHMMX format, where X is wind speed unit
  unless ($time=~/^(\d{2})(\d{2})(\d)$/) {return "BADTIME: $time";}
  my($hour, $minute) = ($1, $2);
  my($wsm) = $3;

  # latitude is Qxxxxx, where xxxxx=lat*1000
  unless ($lat=~/^(\d)(\d{5})$/) {return "BADLAT: $lat";}
  my($quadrant) = $1;
  $lat = $2/1000;

  # lon is just lon*1000
  unless ($lon=~/^(\d{6})$/) {return "BADLON: $lon";}
  $lon /= 1000;

  # correct latitude/longitude for quadrant
  if ($quadrant==5 || $quadrant==7) {$lon*=-1;}
  if ($quadrant==3 || $quadrant==5) {$lat*=-1;}

  # and put into results
  $rethash{id} = $id;
  $rethash{latitude} = $lat;
  $rethash{longitude} = $lon;
  $rethash{time} = "$year-$month-$day $hour:$minute";

  # nuke until section 111
  while (@chunks && (shift(@chunks)!~/^111\d\d/)) {}

  for $i (@chunks) {
    # only care about temperature/pressure/wind
    unless ($i=~/^[0124]\d{4}$/) {next;}

    debug("CHUNK: $i");

    # temperature (1xttt, x=sign, ttt=temperature*10 Celsius)
    if ($i=~/^1(0|1)(\d{3})/) {
      debug("SUB: $1, $2");
      debug($2/10, 0.5<=>$1);
      $rethash{temperature} = $2/10*(0.5<=>$1);
      next;
    }

    # dewpoint (2xttt, same convention as temperature)
    if ($i=~/^2(0|1)(\d{3})/) {
      $rethash{dewpoint} = $2/10*(0.5<=>$1);
      next;
    }

    # humidity (29xxx, alternative to dewpoint, xxx = humidity%*10)
    if ($i=~/^29(\d{3})/) {
      $rehash{humidity} = $1/100;
    }

    # pressure (4xxxx) where xxxx is hectopascals*10 last four digits
    if ($i=~/4(\d{4})$/) {
      $rethash{pressure} = ($1+($1<5000?10000:0))/10;
      next;
    }

    # wind direction and speed
    if ($i=~/0(\d{2})(\d{2})$/) {
      ($rethash{winddir}, $rethash{windspeed}) = ($1*10,$2);
      # if wind speed was given in m/s, convert to knots
      if ($wsm==0 || $wsm==1) {$rethash{windspeed} *= 1.9438445;}
    }

  }
  return %rethash;
}


# parse_metar(string): parses a METAR string to put into a db

sub parse_metar {
  my($a)=@_;

  my(%b)=(); # to hold results
  my(@clouds)=(); # to hold multiple clouds
  my(@weather)=(); # multiple weathers
  my(@leftover)=(); # anything i can't parse

  # we want to store the full metar
  $b{metar}=$a;

  # fix things like "2 1/2SM" and "3/4SM", eval to avoid div by zero death
  eval {$a=~s!(\d+)\s+(\d)/(\d)sm!eval($1+$2/$3)."SM"!ie};
  eval {e$a=~s!(\d)/(\d)sm!eval($1/$2)."SM"!ie};

  # split METAR by spaces
  @b=split(/\s+/,$a);

  # first field is always station
  $b{code}=shift(@b);

  # second field is ddhhmm in GMT
  $aa=shift(@b);

  if ($aa=~/(\d{2})(\d{2})(\d{2})z/i) {
    ($day,$hour,$min)=($1,$2,$3);
  } else {
    return ("ERROR" => "INVALID TIME: $aa");
  }

  # need to figure out month and year (only really an issue at month change)

  # current time/date (just need month and year)
  my($ignore,$ignore,$ignore,$mday,$mon,$year) = gmtime();
  # Perl bizzarely counts months 0..11, and year 0 is 1900
  $mon++;
  $year+=1900;

  # if report date is in future, subtract one month
#  debug("CURRENT TIME: ",time());
#  debug("$year-$mon-$day $hour:$min");
#  debug("REPORT TIME:", str2time("$year-$mon-$day $hour:$min UTC"));

  if (str2time("$year-$mon-$day $hour:$min UTC") > time()) {
    $mon--;
    if ($mon==0) {$year--; $mon=12;}
  }

  # we will return time in sqlite3 format
  $b{time} = "$year-$mon-$day $hour:$min";
  debug("TIME: $b{time}");


  # for convenience, note age of data (caller can toss old data)
#  my($time) = str2time($b{time});
#  $b{age} = time()-$time;
#  debug("AGE: -> $b{age}");

  # remaining fields may be in any order
  for $i (@b) {

    # wind direction/speed
    if ($i=~/^(\d{3}|vrb)(\d{2})kt/i) {
      ($b{winddir},$b{windspeed})=($1,$2);
      next;
    }

    # wind direction/speed (gusting)
    if ($i=~/^(\d{3}|vrb)(\d{2})g(\d{2})kt/i) {
      ($b{winddir},$b{windspeed},$b{gust})=($1,$2,$3); 
      next;
    }

    # visibility
    if ($i=~s/sm$//i) {
      $b{visibility}=$i;
      next;
    }

    # temp/dew point in C (whole degrees)
    # more than 3 digits = bad
    if ($i=~m!^(M?\d{1,3})/(M?\d{1,3})$!) {
      # if we already have a more accurate temperature from RMK, ignore this
      if (exists $b{temperature}) {next;}

      ($b{temperature},$b{dewpoint})=($1,$2);
      if ($b{temperature}=~s/^m//i) {$b{temperature}*=-1;}
      if ($b{dewpoint}=~s/^m//i) {$b{dewpoint}*=-1;}
      next;
    }

    # some reports have temperature only, no dewpoint
    if ($i=~m!^(M?\d{1,3})/$!) {
      # if we already have a more accurate temperature from RMK, ignore this
      if (exists $b{temperature}) {next;}

      $b{temperature}=$1;
      if ($b{temperature}=~s/^m//i) {$b{temperature}*=-1;}
      next;
    }

    # RMK section sometimes has more accurate temperature and dewpoint
    if ($i=~m!^t(\d)(\d{3})(\d)(\d{3})$!i) {
      ($b{temperature},$b{dewpoint})=((-2*$1+1)*$2/10,(-2*$3+1)*$4/10);
      next;
    }

    # Barometric pressure in inches
    if ($i=~/^a(\d{4})/i) {
      $b{pressure}=$1/100; 
      next;
    }

    # Barometric pressure in millibars; we convert to inches for consistency
    if ($i=~/q(\d+)/i) {
      if (exists $b{pressure}) {next;}
      $b{pressure}=$1/33.86388;
      next;
    }

    # Note down how much cloud cover there is
    if ($i=~/^(clr|few|sct|bkn|ovc)/i) {push(@clouds,$i); next;}

    # signifigant weather
    if ($i=~/^([\+\-]?)($abbrevs|)($abbrevs)$/i) {
      # TODO: this returns "-RA", need to return "light rain"
      push(@weather,$i);
      next;
    }

    # Was this report automatically generated?
    if ($i eq "AUTO") {$b{type}="AUTO"; next;}

    # uninteresting stuff (data on sensors, sea-level pressure,
    # non-aviation temperature, remarks separator); we preserve this
    # in the METAR field (and leftover field) but don't break it out
    # into separate fields

    if ($i=~/^ao\d$/i || $i=~/^slp\d+$/i || $i=~/^4(\d{8})$/|| $i eq "RMK") {
      next;
    }

    push(@leftover,$i);
  }

  # combine lists into strings
  $b{cloudcover}=join(" ",@clouds);
  $b{weather}=join(" ",@weather);
  $b{leftover}=join(" ",@leftover);
  return(%b);
}

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
  my(@headers, @hashes);
  my($res) = cache_command("curl http://weather.aero/dataserver_current/cache/metars.cache.csv.gz | gunzip | tail -n +6", "age=300");
  my(@res) = split(/\n/, $res);

  # header line
  @headers = split(/\,/, shift(@res));

  # go through data
  for $i (@res) {
    my(@line) = split(/\,/, $i);
    my(%hash) = {};
    for $j (0..$#headers) {
      $hash{$headers[$j]} = $line[$j];
  }
    push(@hashes, \%hash);
  }

  return @hashes;
}

# <h>return beauty;</h>

true;
