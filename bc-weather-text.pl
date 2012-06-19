#!/bin/perl

# given "Albuquerque, NM" or "Paris, France", attempts to get current
# weather and more
# --nowrap: don't wordwrap the result

# TODO: improve this when data is unavailable

push(@INC, "/usr/local/lib");
require "bclib.pl";
require "bc-weather-lib.pl";

# own tmp dir
dodie('chdir("/var/tmp/bcweathertext")');

# HTTP header (plain text formats nicer, bizarrely)
print "Content-type: text/plain\n\n";

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

LAT:

# nice latitude/longitude for location (not METAR station)
$hash{nicelat} = nicedeg2($hash{latitude},"N");
$hash{nicelon} = nicedeg2($hash{longitude},"E");

# TODO: further limit to stations that actually have reports
# TODO: formula for closest below IS NOT 100% accurate

# approximate ratio of latitude:longitude degree
$ratio = cos($hash{latitude}/180*$PI);

# left join because m.station_id may not exist in stations table

$query = "
SELECT * FROM metar m LEFT JOIN stations s ON (m.station_id = s.metar)
WHERE m.station_id = (
SELECT station_id FROM metar_now m ORDER BY 
 ABS(latitude-$hash{latitude}) +
 $ratio*ABS(longitude-$hash{longitude}) LIMIT 1
) ORDER BY observation_time
;
";

# double minuses are treated as comments in SQL , so change to single positive
$query=~s/\-\-/+/isg;

@res = sqlite3hashlist($query,"/sites/DB/metarnew.db");

debug("RES",unfold(@res),"/RES");

# converting units for all observations here avoids problems below
for $i (@res) {
  %report = %{$i};

  # canonical elevation in ft
  # this doesn't change per observation, so baddish to put it here
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

# @res2 = observations w/ "correct" units
debug("RES2",unfold(@res2),"/RES2");

# @out = thing we're eventually going to print out.

# location data
push(@out,"$hash{city}, $hash{state}, $hash{country} is at $hash{nicelat}, $hash{nicelon}");

# For this station: %recent = most recent observation
%recent = %{$res2[-1]};

debug("RECENT",%recent);

# distance between METAR station and entered location
$text{dist} = round(gcdist($hash{latitude},$hash{longitude},$recent{latitude},$recent{longitude}));

push(@out,"Nearest reporting station is $recent{city}, $recent{state}, $recent{country} ($recent{metar}), at $recent{nicelat}, $recent{nicelon} (elevation $recent{elev} feet), $text{dist} miles away");

# and determine pressure direction (manually, which is less accurate)
# pressure from penultimate report
%oldpress=%{$res2[-2]};
$oldpress=$oldpress{pressure};

if (blank($oldpress)) {
   $pressdir="";
 } elsif ($recent{pressure}>$oldpress) {
   $pressdir=" (rising)";
 } elsif ($recent{pressure}<$oldpress) {
   $pressdir=" (falling)";
 } else {
   $pressdir=" (steady)";
}

# timezone
$ENV{TZ} = $hash{tz};
debug("ENV: $ENV{TZ}*");
$time=strftime("%l:%M %p %Z on %A (%d %b %Y)",localtime(time()));
push(@out,"It's currently $time");

# number of observations
$observations=$#res2+1;
# since $recent{gust} could be 0, max it with $recent{windspeed}
# $maxwind=max($recent{windspeed}, $recent{gust});
# $oldweather=();

# go through old observations
for $i (@res2) {
   %report=%{$i};

   for $ab (split(/\s+/,$report{weather})) {
     # set oldweather hash to types of weather that's occurred
     $oldweather{parse_weather($ab)}=1;
   }


   # max wind is just windspeed if no gust
   $maxwind = $report{gust}||$report{windspeed};

   push(@m, round($maxwind));

   if (blank($report{temperature})) {next;}

   if ($report{temperature}>$maxtemp || blank($maxtemp)) {
      $maxtemp=$report{temperature};
      $maxtime=strftime("%I:%M %p %A",localtime($report{xtime}));
    }

   if ($report{temperature}<$mintemp || blank($mintemp)) {
      $mintemp=$report{temperature};
      $mintime=strftime("%I:%M %p %A",localtime($report{xtime}));
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
$minago=strftime("%I:%M %p %A",localtime($recent{xtime}));
$minago="$minago (".nice_sec($now-$recent{xtime},1)." ago)";

$tempf = $recent{temperature};
$dewf  = $recent{dewpoint};

# two below for calcs only (not sure why $recent{temp_c} fails)
$tempc = ($tempf-32)/1.8;
$dewc = ($dewf-32)/1.8;

$rh= round(100*rh($tempc,$dewc));
$hi= round(hi($tempf, $rh));
if ($hi != round($tempf)) {$ext1=", and a heat index of $hi${DEG}F";}

unless ($recent{windspeed}=~/null/i) {
  $wind=wind($recent{windspeed},$recent{winddir},$recent{gust});
  $wc=floor(.5+wc($tempf,1.1507784538*$recent{windspeed}));
  if ($wc<floor($tempf)) {$ext2=", for a windchill factor of $wc${DEG}F";}
}

$clouds=maxclouds(split(/\s+/,$recent{cloudcover}));
$press=sprintf("%0.2f",$recent{pressure});

# signifigant weather
for $i (split(/\s+/,$recent{weather})) {push(@k,parse_weather($i));}
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

push(@out,"Current METAR (for techies): '$recent{raw_text}'");
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

