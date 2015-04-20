#!/bin/perl

# Given a list of 1st pages of country/administrative area listings,
# create list of URLs to download data, with first pages of each area
# coming first. In other words, download "best" users for each area
# first.

# Input to this program is the pages that link to https://fetlife.com/places

require "/usr/local/lib/bclib.pl";

# this session id is publicly posted at
# http://trilema.com/2015/fetlife-the-meat-market/ (somewhat
# surprising that it still works!)
$fl_cookie = "_fl_sessionid=9c69a3c9bb86f4b1f6ff74064e788824";

for $i (@ARGV) {
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

    # the server I'm using does NOT have parallel, but does have xargs
    # -P, so the 'curl' isn't actually printed below
    print "-H 'Cookie: $fl_cookie' -o $fname '$url'\n";

  }
}
