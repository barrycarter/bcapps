#!/bin/perl

# Adds state nicknames and postal codes to geonames (w/o duplicating!)
# <h>Main purpose of this program is to show how awesome I am!</h>

require "bclib.pl";
# below contains my geonames user/pw
require "/home/barrycarter/bc-private.pl";

# the cookie generated below should last me the entire session
$cmd = "curl -b /tmp/cookies.txt -c /tmp/cookies.txt -e 'http://www.geonames.org/login' -d 'username=$geonames{user}' -d 'password=$geonames{pass}' -d 'rememberme=1' -d 'srv=12' 'http://www.geonames.org/servlet/geonames?'";
($out, $err, $res) = cache_command($cmd, "age=3600");

# this is one of many ways to find the geonameid of all US states
# USA id: 6252001 (cheating by hardcoding this)

# <h>pretend you don't notice there's no password below</h>
($out, $err, $res) = cache_command("curl 'http://api.geonames.org/children?geonameId=6252001&username=$geonames{user}'", "age=3600");

# break into states
while ($out=~s%<geoname>(.*?)</geoname>%%s) {
  $info = $1;

  # create hash from XML (code below won't work for arbitrary XML)
  %hash = ();
  while ($info=~s%<(.*?)>(.*?)</\1>%%) {$hash{$1} = $2;}

  # map state to geonameid
  $id{$hash{toponymName}} = $hash{geonameId};

  # find all existing alternate names (JSON format)
  $cmd = "curl 'http://www.geonames.org/servlet/geonames?srv=150&id=$hash{geonameId}'";
  ($out2, $err2, $res2) = cache_command($cmd, "age=3600");

  # and de-JSON-ify

  # <h>Per standard JSON requirements, useful data must be nested deeply
  # enough to annoy most programmers</h>

  %data = %{JSON::from_json($out2)};
  @data = @{$data{geonames}};

  for $j (@data) {
    %althash = %{$j};
    # mark the name as 'seen' for this state
    $seen{$hash{toponymName}}{$althash{name}} = 1;
  }
}

# and now, the postal codes and nicknames
$nicks = read_file("db/state-names.txt");

for $i (split(/\n/,$nicks)) {
  # ignore comments and empty lines
  if ($i=~/^\#/) {next;}

  # data for state
  ($date, $name, $post, $nick) = split(/\,/,$i);

  # nuke spurious quotes
  $name=~s/\"//isg;
  $nick=~s/\"//isg;

  # NOTE: it turns out all states already have postal abbrevs, so
  # ignoring those

  # if the nickname's already there, ignore
  if ($seen{$name}{$nick}) {next;}

  # URL encode the nickname
  $nick = urlencode($nick);

  # command to update
  $cmd = "curl -b /tmp/cookies.txt -c /tmp/cookies.txt 'http://www.geonames.org/servlet/geonames?srv=151&&alternateNameId=0&id=$id{$name}&alternateName=$nick&alternateNameLocale=en&isOfficialName=false&isShortName=false'";

  # chickening out and just printing command
  print "$cmd\n";

}

