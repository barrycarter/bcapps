#!/bin/perl

# Given a list of 1st pages of country/administrative area listings,
# create list of URLs to download data, with first pages of each area
# coming first. In other words, download "best" users for each area
# first.

# Input to this program is the pages that link to https://fetlife.com/places

require "/usr/local/lib/bclib.pl";

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

while (%pages) {
  $count++;

  # print all URLs that still have pages, delete those that dont
  for $i (keys %pages) {
    if ($pages{$i}>=$count) {
      debug("PRINT: $i -> $count");
    } else {
      delete $pages{$i};
    }
  }
}

die "TESTING";

while (<>) {
#  debug("THUNK: $_");
  if (m%>(.*?) Kinksters living in (.*?)<%) {
    debug("GOT: $1 $2");
  }

  if (m%<a href=\"(.*?)/kinksters\">view more%) {
    debug("GOT: $1");
  }

#  debug("GOT: $_");
}

