#!/bin/perl

# Script where I test code snippets; anything that works eventually
# makes it into a library or real program

# TODO: cleanup this file -- lots of stuff has been (or should be)
# moved to production

# chunks are normally separated with 'die "TESTING";' (TODO: use
# subroutines instead?)

push(@INC, "/usr/local/lib");
require "bclib.pl";
require "bc-astro-lib.pl";
require "bc-weather-lib.pl";
require "bc-kml-lib.pl";
# starting to store all my private pws, etc, in a single file
require "/home/barrycarter/bc-private.pl";
use XML::Simple;
use Data::Dumper 'Dumper';
use Time::JulianDay;
$Data::Dumper::Indent = 0;


# sub END{1};sub END{2};sub END{3};sub END{4}

# use B;
# debug(B::end_av->ARRAY);

in_you_endo();
exec("pwd");

die "TESTING";

# oanda screen cap parsing (screencaps currently NA on github, sorry)

die "TESTING";

# Monte Carlo testing for "dice problem"

# roll 6-sided die 100 times and look at distribution of max frequency

for(1..999999) {
  %count = ();
  $n=0;

  # loop until jump out
  for (;;) {
    $n++;
    if (++$count{int(rand(6)+1)}==10) {last;}
  }

  print "$n\n";

}

# debug(sort {$count{$a} <=> $count{$b}} (keys %count));

die "TESTING";

open(A,"bzcat /home/barrycarter/BCGIT/db/KABQ-hourly.txt.bz2|");

while (<A>) {
  # get data
  /^(\d{4})\-(\d{2})\-(\d{2})\s+(\d{2}):(\d{2}):(\d{2}).*?\s+(.*?)$/;
  ($yr, $mo, $da, $hr, $mi, $se, $tempc) = ($1, $2, $3, $4, $5, $6, $7);

  # ignore null readings
  if ($tempc eq "null") {next;}

  # convert to days since 1 Jan 1901
  $day = julian_day($yr, $mo, $da)-julian_day(1901,1,1)+1;
  # add hr/mi/se
  $day += $hr/24 + $mi/1440 + $se/86400;

  # convert to 10ths for better accuracy (nah)
  # $day/=10;

  # data required for linear regress
  $sum_x2 += $day*$day;
  $sum_y2 += $tempc*$tempc;
  $sum_x += $day;
  $sum_y += $tempc;
  $sum_xy += $day*$tempc;
  $points++;

  # slope so far
  # THIS IS ABSOLUTELY AND COMPLETELY WRONG!
  $den = ($points*$sum_x2) - $sum_x**2;
  if ($den == 0) {next;}
  $num = $points*$sum_xy - $sum_x*$sum_y;
  $a = $num/$den;

print "$a\n";

$vals = << "MARK";

X2: $sum_x2
Y2: $sum_y2
X: $sum_x
Y: $sum_y
XY: $sum_xy
POINTS: $points

MARK
;

  debug("VALS: $vals");
  debug("SLOPE ($points): $a, NUM:$num, DEN: $den","");


}

debug("X: $x");

die "TESTING";

# triangle shading, approach 2

@points = ([0,0], [600,0], [300,600]);
@hues = (0, .825, .5);

for $i (0..600) {
  for $j (0..600) {
  }
}



die "TESTING";

# triangle shading

print "new\nsize 600,600\nsetpixel 0,0,0,0,0\n";

# hue of the bottom point, and the rightmostpoint
$bottomhue = .875;
$rightpointhue = 0.125;

for $y (1..600) {

  # "upside down" triangle
  $xleft = $y/2.;
  $xright = 600-$y/2.;

  # hue for left and right most pixels (assume third point is .25 hue)
  $lefthue = $bottomhue*$y/600;
  $righthue = $rightpointhue - ($rightpointhue-$bottomhue)*$y/600;
  debug("$y: $lefthue .. $righthue");

  for $x ($xleft..$xright) {

    # hue to be based on xy values later
    $hue = $lefthue + ($righthue-$lefthue)*($x-$xleft)/($xright-$xleft);
    # 255 color limit!
    $hue = int($hue*255)/255;

    $color = hsv2rgb($hue,1,1,"format=decimal");
    print "setpixel $x,$y,$color\n";
  }
}

die "TESTING";

$str="KYKN 302135Z AUTO 30022G26KT 10SM CLR A2997 RMK AO1,KYKN,2011-10-30T21:35:00Z,42.92,-97.37,,,300,22,26,10.0,29.970472,,,TRUE,TRUE,,,,,,,CLR,,,,,,,,VFR,,,,,,,,,,,,METAR,398.0";

$str=~s/,,/, ,/isg;

debug(csv($str));

die "TESTING";

# http://programmers.stackexchange.com/questions/116346/get-100-highest-numbers-from-an-infinite-list
# Using whole number to mean "natural number" (n>=1)

for (;;) {
  # new number
  $i = int(rand(2**31));

  # it's too low?
  if ($i < $min) {next;}

  

  debug($i);
}



die "TESTING";

# debug(unfold(recent_weather()));

for $i (recent_weather()) {
  %hash = %{$i};

  my(%newhash) = {};

  $newhash{id} = $hash{station_id};
#  ($newhash{x}, $newhash{y}) = to_mercator($hash{latitude}, $hash{longitude}, "order=xy");
  ($newhash{x}, $newhash{y}) = ($hash{longitude}, $hash{latitude});
  $newhash{label} = $hash{station_id};
  $f = $hash{temp_c}*1.8+32;
  $color = 5/6-($f/100)*5/6;
  $newhash{color} = hsv2rgb($color,1,1,"kml=1&opacity=40");
#  debug("COLOR: $newhash{color}");

  # cleanup
  for $j (sort keys %newhash) {$newhash{$j}=~s/[^a-z0-9 _\.\-\#]//isg;}

  push(@res, \%newhash);
}

debug(unfold(@res));

die "TESTING";

$file = voronoi_map(\@res);
print $file."\n";

die "TESTING";

# SVG thingy

print << "MARK";
<svg xmlns="http://www.w3.org/2000/svg" version="1.1"
 width="1000px" height="1000px"
 viewBox="0 0 1000 1000"
>
MARK
;

# cheating by using stuff you don't have access to, but just testing
for $i (split(/\n/, read_file("/home/barrycarter/.xearth-markers"))) {
  debug("I: $i");
  $i=~/^\s*(\S+)\s+(\S+)\s+\"(.*?)\"/;
  ($lat, $lon, $name) = ($1, $2, $3);
  if (abs($lat)>85) {next;}

  ($x, $y) = to_mercator($lat, $lon, "order=xy");
  $x*=1024;
  $y*=1024;
  debug("$x/$y");

  # this is wrong on purpose
  print qq%<text x="$x" y="$y" fill="red" style="font-size:15">$name</text>\n%;

}

print "</svg>\n";

die "TESTING";

# system("metafsrc2raw.pl -Fsynop_nws sample-data/SHIPS/sn.0040.txt | metaf2xml.pl -TSYNOP -x /tmp/test1.xml");

# system("metafsrc2raw.pl -Fbuoy_nws sample-data/DBUOY/sn.0040.txt | metaf2xml.pl -TBUOY -x /tmp/test2.xml");

# system("metafsrc2raw.pl -Fsynop_nws sample-data/SYNOP/sn.0040.txt | metaf2xml.pl -TSYNOP -x /tmp/test3.xml");

# system("metafsrc2raw.pl -Fmetaf_nws sample-data/METAR/sn.0038.txt | metaf2xml.pl -x /tmp/test4.xml");

# get lat/lon for metar and SYNOP stations
# NOTE: I have a metar.stations table, but it doesn't include SYNOP info alas

@res = sqlite3hashlist("SELECT * FROM stations","db/stations.db");

for $i (@res) {
  %hash = %{$i};
  # set lat/lon for METAR name
  $lat{$hash{metar}} = $hash{latitude};
  $lon{$hash{metar}} = $hash{longitude};
  # and synop station
  $lat{$hash{wmob}*1000+$hash{wmos}} = $hash{latitude};
  $lon{$hash{wmob}*1000+$hash{wmos}} = $hash{longitude};
}

$xml = new XML::Simple;
$data = $xml->XMLin("/tmp/test3.xml");
%data = %{$data};

# passed: test[12].xml

# for test1.xml, fields that look ok: id, lat/lon, cloudcover,
for $i ("metar", "synop", "buoy") {
  @reports = @{$data{reports}{$i}};
  if ($#reports>-1) {last;}
}


for $i (@reports) {
#  debug("I: $i",dump_var("I",\%{$i}));
  %hash = %{$i};
  %ret = weather_hash(\%hash);
#  debug("ALPHA: TIME:",dump_var("ALPHA",{%hash}));

  # debugging so I can sort results and check
  for $j (sort keys %ret) {debug("ALPHA: $j -> $ret{$j}");}

  push(@hashes, {%ret});
}

@queries = hashlist2sqlite(\@hashes, "weather");
warn "For tests, deleting first!";
unshift(@queries, "DELETE FROM weather");
unshift(@queries, "BEGIN");
push(@queries, "COMMIT");
write_file(join(";\n",@queries).";\n", "/tmp/playground.tmp");
system("sqlite3 /home/barrycarter/BCINFO/sites/DB/test.db < /tmp/playground.tmp");


die "TESTING";

srand(1044); # consistent randomness

for $i (1..10) {
  push(@x,rand(),rand());
}

@res = voronoi(\@x,"infinityok=1");
debug("RES",@res);
debug("A",dump_var("POLY",\@res),"B");

while (@x) {
  ($x, $y) = (shift(@x)*100, shift(@x)*100);
  print "setpixel $x $y\n";
}


die "TESTING";

for $i (1..10000) {
  %hash=();
  $hash{y} = rand()*180-90;
  $hash{x} = rand()*360-180;
  $hash{id} = ++$count;
  $hash{label} = "Point $count";
  $hash{color} = hsv2rgb(rand(),1,1,"kml=1");
  push(@l, {%hash});
}

# @poly = voronoi(\@l);

for $i (@l) {
  debug("I: $i");
}

die "TESTING";

=item metaf2xml

METAR:

$hash{temperature}{*} = same as SHIPS/SYNOP
$hash{QNH} = sea level pressure
$hash{sfcWind}{wind} = surface level winds, gusts in gustSpeed
$hash{obsTime}{timeAt} = observation time (hour/minute/day)
@{$hash{cloud}} = cloud cover (as list)
$hash{obsStationId}{id} = station ID

SHIPS AND SYNOP:

$hash{temperature}{air}{temp} = air temperature
$hash{temperature}{dewpoint} = dew point
$hash{temperature}{relHumid[1-4]} = relative humidity, computed in 4 diff ways
$hash{stationPosition} = station position
$hash{SLP} = sea level pressure (adjusted for altitude)
$hash{sfcWind} = surface level winds
$hash{synop_section3}{highestGust}{wind}{speed} = wind gust
$hash{obsTime}{timeAt} = observation time, day and hour only
$hash{totalCloudCover}{oktas} = cloud cover (in 8ths)
$hash{callSign}{id} = ship ID

BUOYS:

$hash{buoy_section1}{temperature}{air}{temp} = air temperature
$hash{buoy_section1}{temperature}{relHumid1} = relative humidity
$hash{stationPosition} = station position
$hash{buoy_section1}{SLP} = sea level pressure (adjusted)
$hash{buoy_section1}{sfcWind}{wind} = wind speed and direction
$hash{obsTime}{timeAt} = observation time (hours/minute/month/day/year-unit)
$hash{buoyId}{id} = buoy ID

=cut

# For SYNOP REPORTS:

# debug("ALL: $all");


die "TESTING";

chdir("/home/barrycarter/BCINFO/sites/DATA/");
print "Content-type: text/plain\n\n";
print join(",",overhead_sky())."\n";

# the latitude/longitude where the sun or moon is overhead
sub overhead_sky {
  ($ra, $dec) = position("sun", $now);
  $sdm = gmst($now);
  $dege = ($ra-$sdm)*15;
  ($lat, $lon) = ($dec, $dege);
  return ($lat, $lon);
}

die "TESTING";

$ship = read_file("/home/barrycarter/BCGIT/sample-data/SHIPS/sn.0005.txt");

# SHIP: BBXX, BUOY: ZZYY

while ($ship=~s/BBXX\s*(.*?)\s*\=//s) {
  $i = $1;
  $i=~s/\s+/ /isg;
  debug("OBS: $i");
  %rethash = parse_ship($i);
  debug("RET:", %rethash);
#  print "$rethash{latitude} $rethash{longitude}\n";
}

die "TESTING";

# all PWS in ABQ
open(A,"grep KNMALBUQ db/wstations.txt|");

while (<A>) {
  chomp;
  push(@cmd, "curl -s -o /tmp/pws-$_.xml 'http://api.wunderground.com/weatherstation/WXCurrentObXML.asp?ID=$_'");
}

write_file(join("\n",@cmd)."\n", "/tmp/pws-suck.sh");
system("parallel < /tmp/pws-suck.sh");

for $i (glob("/tmp/pws-*.xml")) {
  $data = read_file($i);
  %hash = ();

  while ($data=~s%<(.*?)>(.*?)</\1>%%) {$hash{$1}=$2};

  $time = str2time($hash{observation_time_rfc822});

  # wanted: data below
  debug("DATA: $hash{latitude}, $hash{longitude}, $hash{station_id}, $hash{temp_f}, $hash{observation_time_rfc822}, $time");

#  debug("HASH:",%hash);
}

# debug(@cmd);

die "TESTING";

# pipe stuff
$|=1;
my($pid) = open(A,"curl -sN http://test.barrycarter.info/bc-slow-cgi.pl|");

debug("PID: $pid");

while (<A>) {
  print "THUNK: $_\n";
  if (/5$/) {last;}
}

print "LOOP EXIT\n";
system("kill $pid");
close(A);
print "A CLOSED\n";

die "TESTING";

# Moon pos now
debug(position("moon"));

die "TESTING";

($az, $el) = radec2azel(13,-3.67594,35,-106, time());
debug("$az/$el");
($az, $el) = radec2azel(13,-3.67594,35,-106, time()+12*3600*364.2425/365.2425);
debug("$az/$el");



die "TESTING";

=item orbital_elements_mars

2455801.500000000 = A.D. 2011-Aug-28 00:00:00.0000 (CT)
 EC= 9.347044661513308E-02 QR= 1.381233968224160E+00 IN= 1.848831171264561E+00
 OM= 4.952474133890512E+01 W = 2.865779111208922E+02 Tp=  2455629.987808809150
 N = 5.240542156642154E-01 MA= 8.988168683134815E+01 TA= 1.005334943873345E+02
 A = 1.523650236296000E+00 AD= 1.666066504367840E+00 PR= 6.869518252872292E+02

EC=Eccentricity,e
QR=Periapsis distance,q(AU)
IN=Inclination w.r.t xy-plane,i(degrees)
OM=Longitude of Ascending Node,OMEGA,(degrees)
W=Argument of Perifocus,w(degrees)
Tp=Time of periapsis (Julian day number)
N=Mean motion,n(degrees/day)
MA=Mean anomaly,M(degrees)
TA=True anomaly,nu(degrees)
A=Semi-major axis,a(AU)
AD=Apoapsis distance(AU)
PR=Orbital period (day)

=cut


debug(radec2azel(10.4,9.7,35,-106));

die "TESTING";

write_wiki_page("http://wiki.barrycarter.info/api.php", "Hello", "`date`", "Comment", $bcwiki{user}, $bcwiki{pass});

die "TESTING";

($user, $pass) = ($geonames{user}, $geonames{pass});
debug(%geonames);

debug("USER: $user");

# get alt names (shouldn't require login)

$cmd = "curl 'http://www.geonames.org/servlet/geonames?srv=150&id=5551752&callback=getAlternateNames'";

# this just sets cookie
$cmd = qq%curl -b /tmp/cookies.txt -c /tmp/cookies.txt -e "http://www.geonames.org/login" -d "username=$user" -d "password=$pass" -d "rememberme=1" -d "srv=12" "http://www.geonames.org/servlet/geonames?"%;

($out, $err, $res) = cache_command($cmd, "age=3600");

# alt names get info: http://sws.geonames.org/5454711/about.rdf [but
# not real time?]

# now to modify it (this is state of NM, not city of Abq)
$cmd = "curl -b /tmp/cookies.txt -c /tmp/cookies.txt 'http://www.geonames.org/servlet/geonames?srv=151&&alternateNameId=0&id=5481136&alternateName=Land+of+Enchantment&alternateNameLocale=en&isOfficialName=false&isShortName=false'";

die "TESTING";

($out, $err, $res) = cache_command($cmd, "age=3600");

debug($out,$err,$res);

die "TESTING";

# write to a mediawiki installation

# authenticate
$pw = read_file("/home/barrycarter/bc-wiki-pw.txt");
chomp($pw);

# ($token) = cache_command("curl -b /tmp/curlcook.txt -c /tmp/curlcook.txt -H 'Cookie: my_wiki_session=a696f041bcc497ee4cfa201dc4c54e65' http://wiki.barrycarter.info/api.php -d 'action=login&lgname=Barry+Carter&lgpassword=$pw&lgtoken=fadd1feaf1c21187769619ec1e2fa0f9&format=xml'", "age=3600");

($token) = cache_command("curl -b /tmp/curlcook.txt -c /tmp/curlcook.txt http://wiki.barrycarter.info/api.php -d 'action=login&lgname=Barry+Carter&lgpassword=$pw&lgtoken=5df347b68a72fd2185010321debac1b1&format=xml'", "age=3600");

# obtain token

($token) = cache_command("curl -b /tmp/curlcook.txt -c /tmp/curlcook.txt 'http://wiki.barrycarter.info/api.php?action=query&prop=info&intoken=edit&titles=Test%20Page&format=xml'", "age=3600");

debug("TOKEN: $token");

# write with trivial token

($res) = cache_command("curl -b /tmp/curlcook.txt -c /tmp/curlcook.txt 'http://wiki.barrycarter.info/api.php' -d 'action=edit&title=Test&text=article%20content&token=424f1be5e8cb9bdd008fc55b5f337758%2B%5C'", "age=3600");

debug($res);




die "TESTING";

# read EL ELM files

$all = read_file("/home/barrycarter/BCGIT/EL/startmap.elm");

# the .e3d chunks start here (length 64+80=144)
$e3d = hex("947c");

$x = substr($all,$e3d,144);

for ($i=0; $i<=length($all); $i+=144) {
  $x = substr($all,$e3d+$i,144);
  $file = substr($x,0,64);
  $file=~s/\0//isg;
  debug("X: $x", "FILE: $file");
}

die "TESTING";

# solve the EL HE/SR problem

for $i (1..1000) {
  $he = $i/41*16;
  $sr = $i/41*5;
  debug("$i: $he HE, $sr SR");
}

die "TESTING";

# find all el-services.net bots (does not work for other bots)

($res) = cache_command("curl http://bots.el-services.net/", "age=3600");

while ($res=~s/<a class="arrow" href="(.*?)">//) {
  push(@bots, $1);
}

for $i (@bots) {
  debug("BOT: $i");
  ($res) = cache_command("curl http://bots.el-services.net/$i", "age=3600");
  debug("RES: $res");

  # find the location (ugly)
  $res=~s%<tr class="botinfo-location"><td class="botinfo-leftmargin"></td><td class="botinfo-location" colspan="2">(.*?)</td></tr>%%is;
  $loc = $1;
  # break into map, coords
  $loc=~/^\s*(.*?)\s*\[(\d+\s*\,\d+)\]/;
  ($map, $coord) = ($1,$2);
  debug("LOC: $map/$coord");

  # find the selling section (ugly)
  $res=~s/<div id="selling">(.*?)<div id="purchasing">//s;
  ($sell, $buy) = ($1, $res);

  # items
  while ($sell=~s%<td class="public2">(.*?)</td>\s*<td class="public_right">(.*?)</td>\s*<td class="public_right">(.*?)</td>%%is) {
    print join("\t", "SELL", $i, $1, $2, $3)."\n";
  }

  while ($res=~s%<td class="public2">(.*?)</td>\s*<td class="public_right">(.*?)</td>\s*<td class="public_right">(.*?)</td>%%is) {
    print join("\t", "BUY", $i, $1, $2, $3)."\n";
  }


}

die "TESTING";


create_el_tz_file();

=item create_el_tz_file()

Creates a timezone file for Eternal Lands. Use "zic" (as root) to
compile it and then "setenv TZ Test/ELT" to use it. You must create a
"TEST" subdirectory in /usr/share/zoneinfo or the equivalent

=cut

sub create_el_tz_file {
  # current EL time
  my($now) = time();

  # update every minute for the next year (serious overkill?)
  for ($i=$now; $i<=$now+60*24*365.2425; $i+=60) {
    debug("I: $i");
    my(@elt) = unix2el($i);
    debug("$i:", @elt);
  }

}

die "TESTING";

@foo = sendmail("bob\@clown.com", "test20110701-2\@barrycarter.info", "This is my subject", "This is my life");

debug("FOO:",@foo);

die "TESTING";


# TODO: this will NOT catch things that redirect to Desert Pines

$res = cache_command("fgrep -R '[[Desert Pines]] at' /usr/local/etc/wiki/EL-WIKI.NET", "age=3600");

debug(read_file($res));

die "TESTING";

# twitter lib attempt

=item twitter_get_info($sn)

Get info on $sn as a hash

=cut

sub twitter_get_info {
  my($sn) = @_;
  my($file) = cache_command("curl -s 'http://twitter.com/users/show/$sn.json'","retfile=1&age=300");
  my($res) = suck($file);
  my(@hash) = JSON::from_json($res);
  return %{$hash[0]};
}

=item twitter_get_followers($sn)

Get all followers of $sn

=cut

sub twitter_get_followers {
  my($sn) = @_;
  my(@followers);
  my(%info) = twitter_get_info($sn);
  my($numf) = $info{followers_count};
  my($i);

  # loop to get enough pages
  for ($i=1; $i<=int($numf/100)+1; $i++) {
    # get this page of followers
    my($file) = cache_command("curl -s 'http://twitter.com/statuses/followers/$sn.xml?page=$i'", "retfile=1&age=300");
    my($res) = suck($file);

    # HACK: this is ugly, better way to do it?
    my(@page) = ($res=~m%<screen_name>(.*?)</screen_name>%isg);
    push(@followers,@page);
  }

  return @followers;
}

=item twitter_get_friends($sn)

Get friends of $sn (= those people that $sn follows)

TODO: consider merging this w/ twitter_get_followers which is nearly identical

=cut

sub twitter_get_friends {
  my($sn) = @_;
  my(%info) = twitter_get_info($sn);
  my($numf) = $info{friends_count};
  my(@friends);
  my($i);

  # loop to get enough pages
  for ($i=1; $i<=int($numf/100)+1; $i++) {
    # get this page of friends
    my($file) = cache_command("curl -s 'http://twitter.com/statuses/friends/$sn.xml?page=$i'","retfile=1&age=300");
    my($res) = suck($file);
    # HACK: this is ugly, better way to do it?
    my(@page) = ($res=~m%<screen_name>(.*?)</screen_name>%isg);
    push(@friends,@page);
  }

  return @friends;
}


=item twitter_get_friends_followers($sn,$which="friends|followers")

Gets all friends or followers of $sn as list of hashes

=cut

sub twitter_get_friends_followers {
  my($sn,$which) = @_;
  my(@retval);

  # find out how many friends/followers $sn has
  my(%info) = twitter_get_info($sn);
  my($num) = $info{"${which}_count"};
  my($pages) = int($num/100)+1;

  # loop to get enough pages (will never really hit 1000)
  for $i (1..$pages) {
    # get this page of followers
    my($file) = cache_command("curl -s 'http://api.twitter.com/1/statuses/$which/$sn.json?page=$i'", "retfile=1&age=300");
    my($res) = suck($file);
    my(@newres) = @{JSON::from_json($res)};

    if (@newres) {
      push(@retval, @newres);
      debug("RETVAL SIZE: $#retval");
      next;
    }

    return @retval;
  }

}

debug("END");
debug(unfold(twitter_get_friends_followers("barrycarter", "followers")));
# debug(twitter_get_followers("barrycarter"));

die "TESTING";

# RPC-XML

# get password
$pw = read_file("/home/barrycarter/bc-wp-pwd.txt"); chomp($pw);

debug(xmlrpc("http://wordpress.barrycarter.info/xmlrpc.php", "mt.getRecentPostTitles", ["x", "admin", $pw, 10]));

die "TESTING";

debug(xmlrpc("http://wordpress.barrycarter.info/xmlrpc.php", "blogger.getRecentPosts", ["x", "x", "admin", $pw, 10]));

die "TESTING";

# using raw below so i can cache and stuff

$req=<<"MARK";
<?xml version="1.0"?><methodCall>
<methodName>mt.getRecentPostTitles</methodName>
<params>
<param><value>x</value></param>
<param><value>admin</value></param>
<param><value>$pw</value></param>
<param><value><int>10</int></value></param>
</params>
</methodCall>
MARK
;

write_file($req,"/tmp/rpc1.txt");
system("curl -o /tmp/rpc2.txt --data-binary \@/tmp/rpc1.txt http://wordpress.barrycarter.info/xmlrpc.php");
# system("curl -o /tmp/rpc2.txt --data-binary \@/tmp/rpc1.txt http://joomla.barrycarter.info/xmlrpc/index.php");

die "TESTING";

# update existing page attempt
# info about my blog
$pw = read_file("/home/barrycarter/bc-wp-pwd.txt"); chomp($pw);
$author = "barrycarter";
$wp_blog = "wordpress.barrycarter.info";

sub post_to_wp_test {
  my($body, $options) = @_;
  my(%opts) = parse_form($options);
  defaults("live=0");

  # timestamp (in ISO8601 format)
  my($timestamp) = strftime("%Y%m%dT%H:%M:%S", gmtime($opts{timestamp}));

my($req) =<< "MARK";

<?xml version="1.0"?>
<methodCall> 
<methodName>wp.editPage</methodName> 
<params>

<param><value><string>x</string></value></param>

<param><value><string>9410</string></value></param>

<param><value><string>$opts{author}</string></value></param> 

<param><value><string>$opts{password}</string></value></param>

<param> 
<struct> 

<member><name>categories</name> 
<value><array><data><value>$opts{category}</value></data></array></value> 
</member> 

<member>
<name>description</name> 
<value><string><![CDATA[$body]]></string></value>
</member> 

<member> 
<name>title</name> 
<value>$opts{subject}</value> 
</member> 

<member> 
<name>dateCreated</name> 
<value>
<dateTime.iso8601>$timestamp</dateTime.iso8601> 
</value> 
</member> 

</struct> 
</param> 

<param><value><boolean>$live</boolean></value></param> 

</params></methodCall>
MARK
;

  write_file($req,"/tmp/request");
  debug($req);

  if ($globopts{fake}) {return;}

  # curl sometimes sends 'Expect: 100-continue' which WP doesn't like.
  # The -H 'Expect:' below that cancels this
  system("curl -H 'Expect:' -o /tmp/answer --data-binary \@/tmp/request http://$opts{site}/xmlrpc.php");

  debug($req);

  debug(read_file("/tmp/answer"));
}

die "TESTING";

print "Content-type: text/html\n\n";

print `fortune`;

exit(0);

die "TESTING";

push(@INC,"/usr/local/lib");

=item box_option_value($p0, $v, $p1, $p2, $t1, $t2)

Computes the fair value of a box option, given $p0, the current price
of the underlying, $v, the volatility, $p1-$p2 the price range of the
box option, and $t1-$t2, the time interval of the box option in years

=cut

sub box_option_value {
  my($p0, $v, $p1, $p2, $t1, $t2) = @_;


}




die "TESTING";

$data = read_file("data/moonfakex.txt");
$data2 = read_file("data/moonfakey.txt");
@l = nestify($data);
@l = @{$l[0]};
@l2 = nestify($data2);
@l2 = @{$l2[0]};

for $i (@l) {
  @j = @{$i};
  $j[0]=~s/\*\^(\d+)/e+$1/isg;
  push(@xvals, $j[0]);
  push(@yvals, $j[1]);
}

for $i (@l2) {
  @j = @{$i};
  $j[0]=~s/\*\^(\d+)/e+$1/isg;
  push(@xvals2, $j[0]);
  push(@yvals2, $j[1]);
}

$now = time();

for $i (0..48) {
  $time = 1306281600+$i*3600;

  debug(position("moon",$time));
#  debug(position("sun",$time));

  next;



  $xcoord = hermione($time, \@xvals, \@yvals);
  $ycoord = hermione($time, \@xvals2, \@yvals2);

  $ra = atan2($ycoord,$xcoord)/$PI*180;
  if ($ra<0) {$ra+=360;}

  # just to match math
  $dec = (sqrt($xcoord**2+$ycoord**2)-$PI)/$PI*180;

  print "$ra $dec\n";
}

die "TESTING";

$xvals = [1,2,3,4,5,6];
$yvals = [1,8,27,64,125,216];

@xvals=@{$xvals};
@yvals=@{$yvals};

for $i (2..5) {

  # slopes in this, next, prev interv
  $sf = $yvals[$i+1]-$yvals[$i];
  $st = $yvals[$i]-$yvals[$i-1];
  $sp = $yvals[$i-1]-$yvals[$i-2];

  # second derv = average of forward and backward change
  $sd = ($sf-$sp)/2;

  # if this interval is (-.5,+.5), this is quadratic
  $x = 0;
  $test = $sd/2*$x*$x + ($yvals[$i+1]-$yvals[$i])*$x +
 (4*$yvals[$i]+4*$yvals[$i+1] - $sd)/8;
  debug("$x -> $test");
 


}


die "TESTING";

debug(hermite(2.5, $xvals, $yvals));

for $i (100..600) {
  $x = $i/100;
  $h = hermite($x, $xvals, $yvals);
  debug("A",$yvals[floor($x)],$yvals[floor($x+1)],$yvals[floor($x+2)]);
  $hp = h00($x-floor($x))*$yvals[floor($x-1)] +
    h01($x-floor($x))*$yvals[floor($x)];

  debug("HP:", $h-$hp);

#  print $x," ", $h-$hp,"\n";
#  print $x," ", $h-$hp,"\n";
}

die "TESTING";

for $i (0..60) {
  ($ra,$dec) = position("sun", 1305936000+86400*$i);
  print "$dec\n";
}

die "TESTING";


# NOTE: graphs of the hermite functions look fine, so its got to be
# the way I'm taking the slope

for $i (0..100) {
  print h11($i/100)."\n";
}

die "TESTING";

for $i (0..100) {
  print hermite(3+$i/100, $xvals, $yvals);
  print "\n";
}

die "TESTING";

# debug(position("moon"));

debug(position("sun", 1305936000));

die "TESTING";

%points = (
 "Albuquerque" => "35.08 -106.66",
 "Paris" => "48.87 2.33",
 "Barrow" => "71.26826 -156.80627",
 "Wellington" => "-41.2833 174.783333",
 "Rio de Janeiro" => "-22.88  -43.28"
);

$EARTH_CIRC = 4.007504e+7;
$r1 = $EARTH_CIRC/2;

# the dividing circle between two points is a circle w/ center on earth

system("cp /usr/local/etc/sun/gbefore.txt /home/barrycarter/BCINFO/sites/TEST/playground.html");

open(A, ">>/home/barrycarter/BCINFO/sites/TEST/playground.html");

$hue = -1/8;

for $i (sort keys %points) {
  $hue += 1/8;
  for $j (sort keys %points) {
    if ($i eq $j) {next;}

    # don't double do
    if ($done{$i}{$j}) {next;}
    $done{$j}{$i} = 1;

    # vector between cities
    ($lat1, $lon1) = split(/\s+/, $points{$i});
    ($lat2, $lon2) = split(/\s+/, $points{$j});

    ($x1, $y1, $z1) = sph2xyz($lon1, $lat1, 1, "degrees=1");
    ($x2, $y2, $z2) = sph2xyz($lon2, $lat2, 1, "degrees=1");
    ($x3, $y3, $z3) = ($x1-$x2, $y1-$y2, $z1-$z2);

    debug("$x3 $y3 $z3");

    # convert back to polar
    ($theta, $phi) = xyz2sph($x3, $y3, $z3, "degrees=1");
    debug("$theta, $phi");

    # fillcolor
    $col = hsv2rgb($hue,1,1);

  print A << "MARK";

pt = new google.maps.LatLng($phi,$theta);

new google.maps.Circle({
 center: pt,
 radius: 10018760,
 map: map,
 strokeWeight: 1,
 strokeColor: "$col",
 fillOpacity: 0,
 fillColor: "#ff0000"
});

MARK
;
  }
}

system("/bin/cat /usr/local/etc/sun/gend.txt >> /home/barrycarter/BCINFO/sites/TEST/playground.html");

sub xyz2sph {
  my($x,$y,$z,$options) = @_;
  my(%opts) = parse_form($options);

  my($r) = sqrt($x*$x+$y*$y+$z*$z);
  my($phi) = asin($z/$r);
  my($theta) = atan2($y,$x);

  if ($opts{degrees}) {
    return $theta*180/$PI, $phi*180/$PI, $r;
  } else {
    return $theta, $phi, $r;
  }
}

die "TESTING";

# final hermite testing pre-production

for $i (1..10) {
  push(@xvals,$i);
  push(@yvals,$i*$i);
}

debug(@xvals,@yvals);

for ($i=1; $i<=10; $i+=.01) {
  print "$i -> ". hermite($i, \@xvals, \@yvals) ."\n";
}

die "TESTING";

# hermite testing
# <h>No hermits were harmed during these tests</h>

@xvals = @{$l[0][0][2]};
@yvals = @{$l[0][0][3]};

# convert mathematica to perl form
map(s/\*\^/e+/, @xvals);
map(s/\*\^/e+/, @yvals);

# 3.5107128*^9 is April 2nd at 6am is our test case

debug("ALPHA");
debug(hermite(3510755800, \@xvals, \@yvals));

# debug("X",@xvals,"Y",@yvals);

die "TESTING";

sub jd2unix {return(($_[0]-2440587.5)*86400);}
sub unix2jd {return(($_[0]/86400+2440587.5));}

# TODO: cache like crazy!
# moonxyz.txt contains 10 arrays

die "TESTING";

# read_mathematica("data/sunxyz.txt");

$all = read_file("data/sunxyz.txt");

while ($all=~s/[\{\[]([^\{\}\[\]]*)[\}\]]/f2($1)/eisg) {}

# debug($all);
# debug($res[441]);
# debug($res[431]);
# debug($res[400]);
# debug($res[367]);
# debug($res[25]);

# debug("RES",@res);
$all=~s/\s//isg;
debug($all);

@res = f3($all);

debug("RES",unfold(@res));

sub f3 {
  my(@ret);
  my($val) = @_;
  for $i (split(/\,\s*/,$val)) {
    if ($i=~/RES(\d+)/) {
      push(@ret, [f3($res[$1])]);
    } else {
      push(@ret, $i);
    }
  }

  return @ret;
}


# NOTES: only reads (possibly nested) lists, uses static var, returns ref

sub read_mathematica {
  my($file) = @_;
  if ($static{mathematica}{$file}) {return $static{mathematica}{$file};}
  my($data) = read_file($file);

  # only what's between the {}
  $data=~m%(\{.*?\})%isg || warnlocal("No braces: $data");

  # convert mathematica's {} to []
  $data=~tr/\{\}/\[\]/;
  # remove bad chars
  $data=~s/\`//isg;

  debug($data);

  my(@l) = eval($data);
  debug($@);

  debug(@l);

}



die "TESTING";

# use Math::MatrixReal;

# my($a) = Math::MatrixReal->new_random(5, 5);

debug($a);


die "TESTING";

# TESTS
# order is irrelevant
# print convert_time(1001, "%M minutes %S seconds")."\n";
# print convert_time(1001, "%S seconds %M minutes")."\n";

# just in seconds
# print convert_time(1001, "%S seconds")."\n";

# hours and seconds (no minutes)
# print convert_time(3600*7+60*4, "%H hours, %S seconds")."\n";
# with minutes, but weird order
# print convert_time(3600*7+60*4, "%M minutes, %H hours, %S seconds")."\n";

# larger value testing
# below doesn't agree with calendar because of leap year
# print convert_time(time(), "%Y years, %m months, %d days")."\n";
print convert_time(time(), "%Y years, %m months, %d days, %H hours, %M minutes, %S seconds")."\n";
# print convert_time(time(), "%U weeks")."\n";
# print convert_time(time(), "%S seconds plus %U weeks")."\n";
# print convert_time(time(), "%S seconds")."\n";

die "TESTING";

# use Astro::Coord::ECI::Moon;
# my $loc = Astro::Coord::ECI->geodetic (0, 0, 0);
# $moon = Astro::Coord::ECI::Moon->new ();
# @almanac = $moon->almanac($loc, time());

debug(unfold(@almanac));

die "TESTING";

# use PDL::Transform::Cartography;
#        $a = earth_coast();
#        $a = graticule(10,2)->glue(1,$a);
#        $t = t_mercator;
#        $w = pgwin(xs);
#        $w->lines($t->apply($a)->clean_lines());

die "TESTING";


# debug(to_mercator(-85,0,"order=xy"));

debug(from_mercator(0,0));


sub from_mercator {
  my($x, $y, $options) = @_;
  my(%opts) = parse_form($options);
  return atan(sinh($y)), $x*360-180;
}


=item project($lay, $lox, $proj, $dir)

Projects latitude/longitude $lay/$lox to xy coordinates for the
projection $proj; if $dir is 1, does the reverse and converts xy
coordinates to latitude/longitude.

$lax: the latitude or y-coordinate
$loy: the longitude or x-coordinate

(note the order of the xy coordinates are reversed, so that latitude
matches y and longitude matches x)

Note: center of map is 0,0; x and y values range from -0.5 to +0.5

NOT YET DONE!

=cut

sub project {
  my($lay, $lox, $proj, $dir) = @_;

  # this is an ugly way to do this (if/elsif/else)

  # Specifically, google's mercator projection
  if ($proj=~/^merc/) {
    if ($dir) {
      return (atan(sinh($lay)), $lox*360);
    } else {
      return (-1*(log(tan($PI/4+$lay/180*$PI/2))/2/$PI), $lox/360);
    }
  }
}

die "TESTING";

@pts = (35.08, -106.66, 48.87, 2.33, 71.26826, -156.80627, -41.2833,
174.783333, -22.88, -43.28);

debug("ALPHA");
debug(unfold(voronoi(\@pts,"infinityok=1")));

die "TESTING";


exit 1;

die "TESTING";

$all="{this, {is, some, {deeply, nested}, text}, for, you}";

# $all = read_file("data/sunxyz.txt");

# could try to match newline, but this is easier
$all=~s/\n/ /isg;

# <h>It vaguely annoys me that Perl doesn't require escaping curly braces</h>
while ($all=~s/{([^{}]*?)}/handle($1)/seg) {
  $n++;
  debug("AFTER RUN $n, ALL IS:",$all);
}

debug(*$all);

debug("ALL",$all);

debug("ALL",@{$all});


sub handle {
  my($str) = @_;
  debug("Handling $str");
  return \{split(/\,\s*/, $str)};
  debug("L IS:",@l);
  debug("Returning ". \@l);
  return \@l;
}

die "TESTING";

$all="{this, {is, some, {deeply, nested}, text}, for, you}";

while ($all=~s/\{([^{}]*?)\}/f($1)/seg) {
  debug("ALL: $all");
}

sub f {
  my($x) = @_;
  return \$x;
}

debug(*$all);

# sub f {return \{split(",",$_[0])};}

# debug(unfold(@res));


die "TESTING";

debug(project(1,0,"mercator",1));


die "TESTING";

# reading Mathematica interpolation files

$all = read_file("sample-data/manytables.txt");

while ($all=~s/InterpolatingFunction\[(.*?)\]//s) {
  $func = $1;

  # get rid of pointless domain
  # {} are not special to Perl?!
  $func=~s/{{(.*?)}}//;

  # xvals
  $func=~s/{{(.*?)}}//s;
  $xvals = $1;
  debug("XV: $xvals");

  # split and fix
  @xvals=split(/\,|\n/s, $xvals);

  for $i (@xvals) {
    $i=~s/(.*?)\*\^(\d+)/$1*10**$2/iseg;
  }

  debug($func);

}

