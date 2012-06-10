#!/bin/perl

# print updated text as my background image
# came from a hideously much longer program
# probably only useful to me <h>but I like spamming github</h>

require "/home/barrycarter/BCGIT/bclib.pl";

# need current time
$now=time();
chdir(tmpdir());

# shade of blue I want to use
$blue = "128,128,255";

# no X server? die instantly (really only useful for massive rebooting
# and errors early May 2007)
if (system("xset q 1> /dev/null 2> /dev/null")) {exit(0);}

# HACK: leave n top lines blank for apps that "nest" there
# push(@info,"","","");
# last line indicates break between blank and data
push(@err,"","");
push(@info,"______________________");

# TODO: add locking so program doesn't run twice
# TODO: add alarms (maybe)

# This is REALLY REALLY REALLY ugly <h>also, it's ugly</h>
# <h>Did I mention it's ugly?</h>
# what event occurs next?
# TODO: add time of when this event occurs to display?

$nextev = sqlite3val("SELECT event FROM abqastro WHERE time >
DATETIME('now','localtime') AND event NOT IN ('MR','MS', 'Last Quarter', 'First Quarter', 'New Moon', 'Full Moon') ORDER BY time
LIMIT 1", "/home/barrycarter/BCGIT/db/abqastro.db");

debug("NEXTEV: $nextev");

# map event to time of day
%map = (
	"ATS" => "night",
	"NTS" => "astronomical twilight",
	"CTS" => "nautical twilight",
	"SR" => "civil twilight",
	"SS" => "daytime",
	"CTE" => "civil twilight",
	"NTE" => "nautical twilight",
	"ATE" => "astronomical twilight"
	);

push(@info, uc($map{$nextev}));

# @info = stuff we print (to top left corner)
# local and GMT time
push(@info,strftime("MT: %Y%m%d.%H%M%S",localtime($now)));
push(@info,strftime("GMT: %Y%m%d.%H%M%S",gmtime($now)));

# figure out what alerts to suppress
# format of suppress.txt:
# xyz stardate [suppress alert xyz until stardate (local time)]

@suppress = `egrep -v '^#' /home/barrycarter/ERR/suppress.txt`;

# know which alerts to suppress
for $i (@suppress) {
  ($key,$val) = split(/\s+/,$i);
  # if date has already occurred, ignore line
  if ($val < stardate($now)) {next;}
  debug("$key/$val");
  $suppress{$key}=$val;
}

debug("SUPPRESS",%suppress);

# all errors are in ERR subdir (and info alerts are there too)
for $i (glob("/home/barrycarter/ERR/*.err")) {
  for $j (split("\n",read_file($i))) {
    # unless suppressed, push to @err
    if ($suppress{$j} > stardate($now)) {next;}
    push(@err,$j);
  }
}

# informational messages (redundant code, sigh!)
for $i (glob("/home/barrycarter/ERR/*.inf")) {
  for $j (split("\n",read_file($i))) {
    # unless suppressed, push to @info
    if ($suppress{$j} > stardate($now)) {next;}
    push(@info,$j);
  }
}

# local weather (below info, above TZ = not great)
($out, $err, $res) = cache_command("curl -s 'http://api.wunderground.com/weatherstation/WXCurrentObXML.asp?ID=KNMALBUQ80'", "age=120");

# create hash
while ($out=~s%<(.*?)>(.*?)</\1>%%is) {
  ($key, $val) = ($1, $2);
  # reset match to first character
  pos($out)=0;
  debug("KV: $key -> $val");
  $hash{$key}=$val;
}

debug("HASH",%hash);

# I have no cronjob for world time, so...

# hash of how I want to see the zones
%zones = (
 "MT" => "US/Mountain",
 "CT" => "US/Central",
 "ET" => "US/Eastern",
 "PT" => "US/Pacific",
 "GMT" => "GMT",
 "Tokyo" => "Asia/Tokyo",
 "Delhi" => "Asia/Kolkata",
 "Sydney" => "Australia/Sydney",
);

# HACK: manual sorting is cheating/dangerous ... should be able to do
# this auto somehow

@zones= ("PT", "MT", "CT", "ET", "GMT", "Delhi", "Tokyo", "Sydney");

for $i (@zones) {
  $ENV{TZ} = $zones{$i};
  push(@info, strftime("$i: %H%M,%a",localtime(time())));
}

# push output to .fly script
# err gets pushed first (and in red), then info
for $i (@err) {
  # TODO: order these better
  push(@rss, "$i");
  push(@fly, "string 255,0,0,0,$pos,giant,$i");
  $pos+=15;
}

# now info (in blue for now); note $pos is "global"
for $i (@info) {
  # TODO: order these better
  push(@rss, "$i");
  push(@fly, "string $blue,0,$pos,medium,$i");
  $pos+=15;
}

# puts the International Phonetic Alphabet at the bottom right corner
# of the screen (as I am trying to learn it); technique should be
# general enough to work with any file

open(A,"tac /home/barrycarter/BCGIT/db/ipa.txt|");
$br = 768-20; # bottom y value

while (<A>) {
  chomp;
  $br -= 15;
  # this is left justified, which means it won't work for arb files, sigh
  $xval = 950;
  push(@fly, "string $blue,$xval,$br,medium,$_");
  debug("CHOMP: $_");
}

# create RSS (not working, will probably dump)
open(A, ">/var/tmp/bc-bg.rss");
print A qq%<?xml version="1.0" encoding="ISO-8859-1" ?><rss version="0.91">
<channel><title>bc-bg</title><item><title>\n%;
print A join("&lt;br&gt;\n", @rss),"\n";
print A "</title></item></channel></rss>\n";
close(A);

# send header and output to fly file
# tried doing this w/ pipe but failed
# setpixel below needed so bg color is black
# the gray x near middle of screen is so I know a black window isn't covering root
open(A, "> bg.fly");
print A << "MARK";
new
size 1024,768
setpixel 0,0,0,0,0
setpixel 512,384,255,255,255
MARK
    ;

for $i (@fly) {print A "$i\n";}
close(A);

# also copy file since I will need it on other machines
system("fly -q -i bg.fly -o bg.gif; xv +noresetroot -root -quit bg.gif; cp bg.gif /tmp/bgimage.gif");
