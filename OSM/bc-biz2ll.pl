#!/bin/perl

# Uses http://cabq.gov/abq-data to map businesses to
# latitude/longitude with goal of adding them to openstreetmap.org
# (OSM). Actually, a lot of this data was available long before the
# "open data initiative", but I figure I'd throw it a plug.

require "/usr/local/lib/bclib.pl";

&bizaddr2ll;
&biz2ll;

# map business name (from data/firstrun.html.bz2 to
# latitude/longitude, in preparation to add to OSM)

sub biz2ll {
  my(@all) = `bzcat /home/barrycarter/BCGIT/OSM/data/firstrun.html.bz2`;
  my($all) = join("",@all);

  while ($all=~s%<tr>(.*?)</tr>%%s) {
    # extract each business' data
    my($data) = $1;

#    debug("DATA: $data");

    # if no link to Details.asp, this row doesn't contain a business' info
    unless ($data=~/Details.asp/is) {next;}

    # name and address (don\'t need city/zip)
    $data=~m:<td width="40%">(.*?)</td>:;
    my($addr) = $1;
    $data=~m%<a href=.*?>(.*?)</a>%;
    my($name) = $1;

    debug("$name -> $addr");
  }
}

# convert business addresses to lat/lon, return as hash

# NOTE: doing this with ALL ABQ addresses would be much harder, using
# just business addresses makes it easier

sub bizaddr2ll {
  my($data) = read_file("/home/barrycarter/BCGIT/OSM/data/bizll.txt");

  for $i (split(/\n/,$data)) {
    # extract the colored section = address
    # I'm too lazy to match ESC, so just using . below
    $i=~/.01\;31m.\[K(.*?).\[m.\[K/;
    $addr = $1;

    # and now the lat lon
    $i=~/point\((.*?)\)/i;
    $latlon = $1;

    # and hash (global)
    $hash{$addr} = $latlon;

  }
}

die "TESTING";

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





