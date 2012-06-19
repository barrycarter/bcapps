#!/bin/perl

# Uses http://cabq.gov/abq-data to map businesses to
# latitude/longitude with goal of adding them to openstreetmap.org
# (OSM). Actually, a lot of this data was available long before the
# "open data initiative", but I figure I'd throw it a plug.

require "/usr/local/lib/bclib.pl";

# this is a little ugly, but even the unbzipped file isn't THAT big
$all = `bzcat data/firstrun.html.bz2`;

while ($all=~s%<tr>(.*?)</tr>%%s) {
  $data = $1;

  # if no link to Details.asp, this row doesn't contain a business' info
  unless ($data=~/Details.asp/is) {next;}

  # for now, just need the address (which cabq very nicely formats consistently)
  $data=~m:<td width="40%">(.*?)</td>:;
  $addr = $1;

  # simply print this, so I can use out to fgrep -f in list of addresses
  print "$addr\n";
}



