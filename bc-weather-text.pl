#!/bin/perl

# given "Albuquerque, NM" or "Paris, France", attempts to get current
# weather and more
# --nowrap: don't wordwrap the result

# TODO: improve this when data is unavailable

push(@INC, "/usr/local/lib");
require "bclib.pl";

# own tmp dir
dodie('chdir("/var/tmp/bcweathertext")');

# HTTP header (plain text formats nicer, bizarrely)
print "Content-type: text/plain\n\n";

# list of METAR weather abbrevs (TODO: put this somewhere better, and
# non-redundant)

%ABBREV=("BC" => lc("Patches"),
	 "BL" => lc("Blowing"),
	 "DR" => lc("Low Drifting"),
	 "FZ" => lc("Supercooled/freezing"),
	 "MI" => lc("Shallow"),
	 "PR" => lc("Partial"),
	 "SH" => lc("Showers"),
	 "TS" => lc("Thunderstorm"),
	 "BR" => lc("Mist"),
	 "DS" => lc("Dust Storm"),
	 "DU" => lc("Widespread Dust"),
	 "DZ" => lc("Drizzle"),
	 "FC" => lc("Funnel Cloud"),
	 "FG" => lc("Fog"),
	 "FU" => lc("Smoke"),
	 "GR" => lc("Hail"),
	 "GS" => lc("Small Hail/Snow Pellets"),
	 "HZ" => lc("Haze"),
	 "IC" => lc("Ice Crystals"),
	 "PL" => lc("Ice Pellets"),
	 "PO" => lc("Dust/Sand Whirls"),
	 "PY" => lc("Spray"),
	 "RA" => lc("Rain"),
	 "SA" => lc("Sand"),
	 "SG" => lc("Snow Grains"),
	 "SN" => lc("Snow"),
	 "SQ" => lc("Squall"),
	 "SS" => lc("Sandstorm"),
	 "UP" => lc("Unknown Precipitation (Automated Observations)"),
	 "VA" => lc("Volcanic Ash")
	);

# do everything in UTC
delete($ENV{TZ});
$now = time();

# turn this into a "webapp" by using hostname as location
if ($ENV{HTTP_HOST}=~/^(.*?)\.weather\..*$/) {
  # sanitization occurs below
  $city = $1;
} else {
  print "URL does not appear to have correct format\n";
  exit(0);
}

# if numeric, assume lat/lon (allow x as start, since "-..." won't resolve)
if ($city=~/^x?([0-9\.\-]+)[^0-9\.\-]([0-9\.\-]+)$/) {
  ($hash{latitude},$hash{longitude}) = ($1,$2);
  $hash{city} = "Latitude $hash{latitude}";
  $hash{state} = "Longitude $hash{longitude}";
  $hash{country} = "Earth";
  # <h>it took me 25+ years to use my first goto!</h>
  goto LAT;
}

# <h>security thru turning everything into dots</h>
$city=~s/[^a-z]/./isg;
debug("CITY: $city");
$res = `bc-cityfind.pl '$city'`;
chomp($res);

# not found?
unless ($res) {print "Unable to find: $city\n"; exit(0);}

# Set $hash using XML reply above
while ($res=~s%<(.*?)>(.*?)</\1>%$hash{$1}=$2;%iseg) {}

debug("HASH",unfold(%hash));

# TODO: this is ugly for two reasons:
# 1) geonames already lists all metar stations
# 2) I could join bc-cityfind.pl's query to get everything in one go
# 3) converting lat/lon to 3D is just plain weird

LAT:

# ($x,$y,$z) = sph2xyz($hash{longitude},$hash{latitude},1,"degrees=1");

# nice latitude/longitude for location (not METAR station)
$hash{nicelat} = nicedeg2($hash{latitude},"N");
$hash{nicelon} = nicedeg2($hash{longitude},"E");

# TODO: further limit to stations that actually have reports
# TODO: formula for closest below IS NOT 100% accurate

# approximate ratio of latitude:longitude degree
$ratio = cos($hash{latitude}/180*$PI);

$query = "
SELECT * FROM metar m JOIN stations s ON (m.station_id = s.metar)
WHERE m.station_id = (
SELECT station_id FROM metar_now m ORDER BY 
 ABS(latitude-$hash{latitude}) +
 $ratio*ABS(longitude-$hash{longitude}) LIMIT 1
) ORDER BY observation_time
;
";

# JOIN stations s ON (m.station_id=s.metar)
# WHERE m.station_id = 
# (SELECT s.metar
# FROM stations s JOIN metar m ON (s.metar = m.station_id)
# ORDER BY (x-$x)*(x-$x) + (y-$y)*(y-$y) + (z-$z)*(z-$z)
# LIMIT 1)
#ORDER BY observation_time DESC
# ;
# ";

# double minuses are treated as comments, so...
$query=~s/\-\-/+/isg;

@res = sqlite3hashlist($query,"/sites/DB/metarnew.db");

debug("RES",unfold(@res),"/RES");

# converting units for all observations here avoids problems below
for $i (@res) {
  %report = %{$i};

  # canonical elevation in ft
  $report{elev} = round(convert($report{elevation_m}, "m", "ft"));

  # canonical pressure in inches
  $report{pressure} = $report{altim_in_hg};

  # canonical temperature + dewpoint in Farenheit
  $report{temperature} = convert($report{temp_c}, "c", "f");
  $report{dewpoint} = convert($report{dewpoint_c}, "c", "f");

  # wind speed + gust (in mph)
  $report{windspeed} = convert($report{wind_speed_kt}, "kt", "mph");
  $report{gust} = convert($report{wind_gust_kt}, "kt", "mph");

  # signifigant weather (as abbreviation)
  $report{weather} = $report{wx_string};

  # time in regular and Unix formats
  $report{time} = $report{observation_time};
  $report{xtime} = str2time($report{observation_time});

  # the prettyprinted latitude and longitude
  $report{nicelat} = nicedeg2($report{latitude}, "N");
  $report{nicelon} = nicedeg2($report{longitude}, "E");

  push(@res2, {%report});

}

debug("RES2",unfold(@res2),"/RES2");

# @out = thing we're eventually going to print out.

# location data
push(@out,"$hash{city}, $hash{state}, $hash{country} is at $hash{nicelat}, $hash{nicelon}");

# For this station: %ai = most recent observation; @e = all observations
%ai = %{$res2[0]};
@e = @res2;

# distance between METAR station and entered location
$ai{dist} = round(gcdist($hash{latitude},$hash{longitude},$ai{latitude},$ai{longitude}));

push(@out,"Nearest reporting station is $ai{city}, $ai{state}, $ai{country} ($ai{metar}), at ".nicedeg2($ai{latitude},"N").", ".nicedeg2($ai{longitude},"E")." (elevation $ai{elev} feet), $ai{dist} miles away");

# and determine pressure direction (manually)
%oldpress=%{$e[1]};
$oldpress=$oldpress{pressure};

if (blank($oldpress)) {
   $pressdir="";
 } elsif ($f{pressure}>$oldpress) {
   $pressdir=" (rising)";
 } elsif ($f{pressure}<$oldpress) {
   $pressdir=" (falling)";
 } else {
   $pressdir=" (steady)";
}

# timezone
$ENV{TZ} = $hash{tz};
debug("ENV: $ENV{TZ}*");
$time=strftime("%l:%M %p %Z on %A",localtime(time()));
push(@out,"It's currently $time");

# number of observations
$observations=$#e+1;
# below makes sense because $f{gust} maybe undefined and thus essentially 0
$maxwind=max($f{windspeed}, $f{gust});
$oldweather=();

# go through old observations
for $i (@e) {
   %f=%{$i};

   for $ab (split(/\s+/,$f{weather})) {
         $oldweather{parse_weather($ab)}=1;
      }

   push(@m, $maxwind);

   if (blank($f{temperature})) {next;}

   if ($f{temperature}>$maxtemp || blank($maxtemp)) {
      $maxtemp=$f{temperature};
      $maxtime=strftime("%I:%M %p %A",localtime($f{xtime}));
    }

   if ($f{temperature}<$mintemp || blank($mintemp)) {
      $mintemp=$f{temperature};
      $mintime=strftime("%I:%M %p %A",localtime($f{xtime}));
    }
}

$maxwindmph=max(@m);

unless (blank($maxwindmph)) {
   $MAXWINDPHRASE=", the maximum wind speed was $maxwindmph mph";
}

$printmaxtemp = round($maxtemp);
$printmintemp = round($mintemp);

$extrema="Over the past 24 hours ($observations observations), the high was $printmaxtemp${DEG}F ($maxtime), the low was $printmintemp${DEG}F ($mintime)$MAXWINDPHRASE";

$aa=join(", ",keys(%oldweather));

unless (blank($aa)) {
  $extrema="$extrema, and there's been: $aa";
}

# TODO: restore easter_egg()?
# TODO: readd WMO info and SYNOP high/low (more accurate than METAR)
# TODO: add TAFs?
# TODO: add other extrema?
#  (incl calculated values like wind chill/relative humidity)?

# spit out the output
$minago=strftime("%I:%M %p %A",localtime($f{xtime}));
$minago="$minago (".nice_sec($now-$f{xtime},1)." ago)";

$tempf = $f{temperature};
$dewf  = $f{dewpoint};
$rh=floor(.5+100*rh($f{temperature},$f{dewpoint}));
$hi=floor(.5+hi($f{temperature}*1.8+32,100*rh($f{temperature},$f{dewpoint})));
debug("$hi vs $printtempf");
if ($hi!=round($tempf)) {$ext1=", and a heat index of $hi${DEG}F";}

unless ($f{windspeed}=~/null/i) {
  $wind=wind($f{windspeed},$f{winddir},$f{gust});
  $wc=floor(.5+wc($tempf,1.1507784538*$f{windspeed}));
  if ($wc<floor($tempf)) {$ext2=", for a windchill factor of $wc${DEG}F";}
}

$clouds=maxclouds(split(/\s+/,$f{cloudcover}));
$press=sprintf("%0.2f",$f{pressure});

# signifigant weather
for $i (split(/\s+/,$f{weather})) {push(@k,parse_weather($i));}
$weather=join(", ",@k);

unless ($dewf=~/null/i) {
  $printdewf = round($dewf);
  $DEWPOINTPHRASE=", with a dewpoint of $printdewf${DEG}F, for a relative humidity of $rh%$ext1";
}

$printtempf = round($tempf);
push(@out,"At $minago, it was $printtempf${DEG}F$DEWPOINTPHRASE");

unless (blank($clouds)) {push(@out,"Skies are $clouds");}
unless (blank($weather)) {push(@out,"There's $weather");}
unless (blank($wind)) {push(@out,"Winds are $wind$ext2");}

push(@out,"The barometric pressure is $press inches$pressdir");

push(@out,$extrema);

push(@out,"Current METAR (for techies): '$f{observation}'");
unshift(@out,"Do not rely on this information");

if ($NOWRAP) {
  $out=join(". ",@out).".";
} else {
  $out=wrap(join(". ",@out).".",70);
}

print "$out\n";

# nicedeg2(deg,east-north): returns a nice version of degree (lat/lon)

sub nicedeg2 {
  my($deg,$en,$sign,$secs)=@_;
  if ($deg<0) {$sign=-1; $deg=-$deg;} # positive only
  $secs=$deg*3600;
  if ($sign==-1 && $en eq "N") {$en="S";}
  if ($sign==-1 && $en eq "E") {$en="W";}
  return(sprintf("%d\*%0.2d\'%0.2d\" $en",$secs/3600,$secs/60%60,$secs%60));
}

# easteregg(): if a location can't be found, look for Easter Egg,
# otherwise quit

sub easteregg {
  my($aa)=join(" ",@ARGV);
  
  if ($aa=~/constantinople/i) {
    $ab="Istanbul was Constantinople, now it's Istanbul, not Constantinople. Why did Constantinople get the works? That's nobody's business but the Turks... Is-tan-bul";
  } elsif ($aa=~/south_park/) {
    $ab="Oh my god, you killed Kenny! (you bastard!)";
  } else {
    $ab="Sorry, couldn't find $aa";
  }

  print wrap($ab,70);
  exit(-1);
}

=item parse_weather($abbrev)

Given an abbreviation for a type of weather (from %ABBREV), return the
full form of that weather.

Essentially a trivial wrapper around the %ABBREV hash.

PEDANTIC: this returns +FC as "heavy funnel cloud"; NWS calls it "tornado"

=cut

sub parse_weather {
  my($abbrev) = @_;
  my(@res);

  # + and - indicate heavy/light conditions
  if ($abbrev=~s/^\+//) {push(@res,"heavy");}
  if ($abbrev=~s/^\-//) {push(@res,"light");}

  # cases like SHRA meaning "showers of rain", then regular two
  # letter, then unknown
    if ($abbrev=~/^(..)(..)$/) {
    push(@res,"$ABBREV{$1} $ABBREV{$2}");
  } elsif ($abbrev=~/^(..)$/) {
    push(@res,"$ABBREV{$1}");
  } else {
    push(@res,"UNKNOWN: $abbrev");
  }

  return(join(" ",@res));
}

