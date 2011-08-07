#!/bin/perl

# given "Albuquerque, NM" or "Paris, France", attempts to get current
# weather and more
# --nowrap: don't wordwrap the result

push(@INC, "/usr/local/lib");
require "bclib.pl";

# do everything in UTC
delete($ENV{TZ});
$now = time();

# read the args as one big arg and find city
# reason: bc-cityfind.pl interprets multiple args as multiple cities
$city = join(" ",@ARGV);

# if purely numeric, assume lat/lon
# TODO: improve this
if ($city=~/^([0-9\.\-]+)[^0-9\.\-]([0-9\.\-]+)$/) {
  ($lat,$lon) = ($1,$2);
  # <h>it took me 25+ years to use my first goto!</h>
  goto LAT;
}

# <h>security thru turning everything into dots</h>
$city=~s/[^a-z]/./isg;
debug("CITY: $city");
$res = `bc-cityfind.pl '$city'`;
chomp($res);

# TODO: this is sample until I get this thing on bcinfo
$res = "
<response>
<city>Albuquerque</city>
<cityq>albuquerque</cityq>
<country>United States</country>
<geonameid>5454711</geonameid>
<latitude>35.0844869067959</latitude>
<longitude>-106.651138463684</longitude>
<population>487378</population>
<state>New Mexico</state>
<tz>America/Denver</tz>
</response>
";

# not found?
unless ($res) {print "Unable to find: $city\n"; exit(0);}

while ($res=~s%<(.*?)>(.*?)</\1>%$hash{$1}=$2;%iseg) {}

# TODO: this is ugly for two reasons:
# 1) geonames already lists all metar stations
# 2) I could join bc-cityfind.pl's query to get everything in one go
# 3) converting lat/lon to 3D is just plain weird

LAT:

($x,$y,$z) = sph2xyz($hash{longitude},$hash{latitude},1,"degrees=1");

# TODO: further limit to stations that actually have reports
$query = "
ATTACH '/sites/DB/metar.db' AS metar;
SELECT *, w.metar AS metarreport
 FROM weather w JOIN stations s ON (w.code=s.metar)
 WHERE w.code = 
 (SELECT s.metar
 FROM stations s JOIN metar.weather w ON (s.metar = w.code)
 ORDER BY (x-$x)*(x-$x) + (y-$y)*(y-$y) + (z-$z)*(z-$z)
 LIMIT 1)
ORDER BY time DESC
;
";
# double minuses are treated as comments, so...
$query=~s/\-\-/+/isg;

@res = sqlite3hashlist($query,"/sites/DB/stations.db");

push(@out,"$city, $state, $country is at ".nicedeg2($lat,"N").", ".nicedeg2($lon,"E"));

# For this station: %ai = most recent observation; @e = all observations
%ai = %{$res[0]};
@e = @res;

# meters to feet <h>metric system? never heard of it!</h>
$ai{elev} = round($ai{elevation}/.3048);
# distance between METAR station and entered location
$ai{dist} = round(gcdist($lat,$lon,$ai{latitude},$ai{longitude}));

push(@out,"Nearest reporting station is $ai{city}, $ai{state}, $ai{country} ($ai{metar}), at ".nicedeg2($ai{latitude},"N").", ".nicedeg2($ai{longitude},"E")." (elevation $ai{elev} feet), $ai{dist} miles away");

# for the most recent observation, fill in hash h
# TODO: am I just copying %ai to %h... looks like it
%f=%{$e[0]};
for $i (keys %f) {$h{$i}=$f{$i};}

# and special case for xtime
$h{xtime} = str2time("$h{time} UTC");

# and determine pressure direction

%oldpress=%{$e[1]};
$oldpress=$oldpress{pressure};
debug("OLD PRESSURE: $oldpress");

if (blank($oldpress)) {
   $pressdir="";
 } elsif ($h{pressure}>$oldpress) {
   $pressdir=" (rising)";
 } elsif ($h{pressure}<$oldpress) {
   $pressdir=" (falling)";
 } else {
   $pressdir=" (steady)";
}

# timezone
$ENV{TZ} = $tz;
debug("ENV: $ENV{TZ}*");
$time=strftime("%l:%M %p %Z on %A",localtime(time()));
push(@out,"It's currently $time");

$observations=$#e+1;
$maxwind=max($f{windspeed},$f{gust});
$oldweather=();

for $i (@e) {
   %f=%{$i};

   # compute Unix time (sqlite3's datetime funcs choke on yyyy-m-dd [one m])
   $f{xtime} = str2time("$f{time} UTC");

   debug(unfold(%f));

   for $ab (split(/\s+/,$f{weather})) {
         $oldweather{parse_weather($ab)}=1;
      }

   push(@m,max($f{windspeed},$f{gust}));

   if ($f{temperature}=~/null/i) {next;}

   if ($f{temperature}>$maxtemp || blank($maxtemp)) {
      $maxtemp=$f{temperature};
      $maxtime=strftime("%I:%M %p %A",localtime($f{xtime}));
    }

   if ($f{temperature}<$mintemp || blank($mintemp)) {
      $mintemp=$f{temperature};
      $mintime=strftime("%I:%M %p %A",localtime($f{xtime}));
    }
}

$maxtempf=ctof($maxtemp);
$mintempf=ctof($mintemp);
$maxwindknots=max(@m);

unless (blank($maxwindknots)) {
  # knots to mph
   $maxwindmph=int(.5+$maxwindknots*1.1507784538);
   $MAXWINDPHRASE=", the maximum wind speed was $maxwindmph mph";
}

$extrema="Over the past 24 hours ($observations observations), the high was $maxtempf${DEG}F ($maxtime), the low was $mintempf${DEG}F ($mintime)$MAXWINDPHRASE";

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
$minago=strftime("%I:%M %p %A",localtime($h{xtime}));
$minago="$minago (".nice_sec($now-$h{xtime},1)." ago)";

$tempf=ctof($h{temperature});
$dewf=ctof($h{dewpoint});
$rh=floor(.5+100*rh($h{temperature},$h{dewpoint}));
$hi=floor(.5+hi($h{temperature}*1.8+32,100*rh($h{temperature},$h{dewpoint})));
if ($hi!=$tempf) {$ext1=", and a heat index of $hi${DEG}F";}

unless ($h{windspeed}=~/null/i) {
  $wind=wind($h{windspeed},$h{winddir},$h{gust});
  $wc=floor(.5+wc($tempf,1.1507784538*$h{windspeed}));
  if ($wc<$tempf) {$ext2=", for a windchill factor of $wc${DEG}F";}
}

$clouds=maxclouds(split(/\s+/,$h{cloudcover}));
$press=sprintf("%0.2f",$h{pressure});

# signifigant weather
for $i (split(/\s+/,$h{weather})) {push(@k,parse_weather($i));}
$weather=join(", ",@k);

unless ($dewf=~/null/i) {
  $DEWPOINTPHRASE=", with a dewpoint of $dewf${DEG}F, for a relative humidity of $rh%$ext1";
}

push(@out,"At $minago, it was $tempf${DEG}F$DEWPOINTPHRASE");

unless (blank($clouds)) {push(@out,"Skies are $clouds");}
unless (blank($weather)) {push(@out,"There's $weather");}
unless (blank($wind)) {push(@out,"Winds are $wind$ext2");}

push(@out,"The barometric pressure is $press inches$pressdir");

push(@out,$extrema);

push(@out,"Current METAR (for techies): '$h{metarreport}'");
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


