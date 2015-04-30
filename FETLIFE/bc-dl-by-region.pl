#!/bin/perl

# Given a list of 1st pages of country/administrative area listings,
# create list of URLs to download data, with first pages of each area
# coming first. In other words, download "best" users for each area
# first.

# --sessionid: a valid fetlife session id

require "/usr/local/lib/bclib.pl";

unless ($globopts{sessionid}) {die("--sessionid required");}
dodie('chdir("/home/barrycarter/FETLIFE/FETLIFE-BY-REGION")');

# curl commands (lets me change quickly if needed)
my($cmd) = "curl --compress -A 'Fauxzilla' --socks4a 127.0.0.1:9050 -H 'Cookie: _fl_sessionid=$globopts{sessionid}'";

# and the command to run on remote server (same except no TOR)
my($cmd2) = "curl --compress -A 'Fauxzilla' -H 'Cookie: _fl_sessionid=$globopts{sessionid}'";

# TODO: add timestamps to everything as we will be on infinite loop(?)

# get list of places
my($out,$err,$res) = cache_command2("$cmd -o places.html 'https://fetlife.com/places'","age=864000");
my($data) = read_file("places.html");

open(A,"|parallel -j 5");

while ($data=~s%"/(countries|administrative_areas)/(\d+)">(.*?)</a>%%) {
  my($type,$num,$name) = ($1,$2,$3);
  my($fname) = "$type-$num.txt";

  push(@files, $fname);

  # TODO: add a time test here, not just an existence test
  if (-f $fname && -M $fname < 1) {next;}

#  my($res) = cache_command2("$cmd -o $type-$num.txt 'https://fetlife.com/$type/$num'","age=86400");
  debug("DOING: $fname");
  print A "$cmd -o $fname 'https://fetlife.com/$type/$num'\n";
}

close(A);

for $i (@files) {
  debug("I: $i");
  my($data) = read_file($i);
  # <h>the abbreviation for country below is in honor of Fetlife</h>
  my($num,$cunt,$url);

  unless ($data=~m%>(.*?) Kinksters living in (.*?)<%) {warn "NO DATA IN: $i";}
  ($num,$cunt) = ($1,$2);

  unless ($data=~m%<a href=\"(.*?)/kinksters\">view more%) {warn "NO URL: $i";}
  my($url) = $1;

  $num=~s/,//g;

  # number of pages for this url
  # some URLs have multiple pages, always choose highest value
  # adding 1 below to allow for growth during dl
  $pages{$url} = max($pages{$url},ceil($num/16)+1);
}

# glitch cases (countries w/ admin areas already on page, city I
# myself am in, etc)

for $i ("/countries/233", "/cities/8630", "/cities/11529") {delete $pages{$i};}

# print page 1 for each URL, then page 2, etc
# there might be more efficient ways to do this? (but fast enough for me)

my(@curls);

while (%pages) {
  $count++;

  # print all URLs that still have pages, delete those that dont
  for $i (keys %pages) {
    # ignore and delete URLs that have a lower page count
    if ($pages{$i}<$count) {delete $pages{$i}; next;}

    # url for download and output filename (can't use -O will overwrite)
    my($url) = "https://fetlife.com/$i/kinksters?page=$count";
    my($fname) = "fetlife-$i-p$count.txt";

    # this is just to make a "pretty" filename
    $fname=~s/administrative_areas/aa-/g;
    $fname=~s/countries/co-/g;
    $fname=~s/(\d+)/sprintf("%0.6d",$1)/iseg;
    $fname=~s%/%%g;

    # using "xargs -n 1 -P time (command)" instead of parallel
    print "$cmd2 -sS -o $fname '$url'\n";
  }
}

