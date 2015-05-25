#!/bin/perl

# Stores the daily changes files from geonames.org since no one else
# seems to do this?!

require "/usr/local/lib/bclib.pl";
my($target) = "/sites/ONEOFF/GEONAMES/";

# plan to do this hourly, which is overkill...
my($out,$err,$res) = cache_command2("curl http://download.geonames.org/export/dump/", "age=1800");

while ($out=~s%<a href="(.*?)">%%is) {
  my($url) = $1;
  # only want ones with dates in them
  unless ($url=~/\d{4}\-\d{2}\-\d{2}/) {next;}

  # do I have it already?
  if (-f "$target/$url") {next;}

  debug("GETTING: $target/$url");

  ($out2,$err2,$res2) = cache_command2("curl -o $target/$url http://download.geonames.org/export/dump/$url");

}
