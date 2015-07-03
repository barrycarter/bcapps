#!/bin/perl

# Given a list of 1st pages of country/administrative area listings,
# create list of URLs to download data, with first pages of each area
# coming first. In other words, download "best" users for each area
# first.

# major changes 17 May 2015 to localize the process, test for errors,
# allow for mirroring, etc

# --sessionid: a valid fetlife session id
# --subdir: the subdirectory to which I am downloading

require "/usr/local/lib/bclib.pl";

defaults("xmessage=1");

unless ($globopts{sessionid} && $globopts{subdir}) {
  die("Usage: $0 --sessionid=x --subdir=x");
}

dodie('chdir("/mnt/extdrive2/FETLIFE-BY-REGION/$globopts{subdir}")');

my(%files);

# curl commands (lets me change quickly if needed)
# -f as crude substitute for checking for 91 byte files
my($cmd) = "curl -f --create-dirs --compress -A 'Fauxzilla' --socks4a 127.0.0.1:9050 -H 'Cookie: _fl_sessionid=$globopts{sessionid}'";

# multi-argument curl is more efficient
open(B,"|xargs -r $cmd");

# dl country first pages (this overcounts by two)
# TODO: do check places.html to see if there is new highwater mark
for $i (1..250) {
  # dont re dl for a given subdir
  if (-f "countries-$i.txt") {next;}
  print B "-o countries-$i.txt https://fetlife.com/countries/$i\n";
}

# we need these files to proceed, so must close and reopen
close(B);

# TODO: add timestamps to everything as we will be on infinite loop(?)

# pages per country

for $i (1..250) {
  my($data) = read_file("countries-$i.txt");

  # <h>the abbreviation for country below is in honor of Fetlife</h>
  my($num,$cunt,$url);

  unless ($data=~m%>(.*?) Kinksters living in (.*?)<%) {warn "NO DATA IN: $i";}
  ($num,$cunt) = ($1,$2);

  unless ($data=~m%<a href=\"(.*?)/kinksters\">view more%) {warn "NO URL: $i";}
  my($url) = $1;

  $num=~s/,//g;

  # number of pages for this url
  # some URLs have multiple pages, always choose highest value
  # adding 2 below to allow for growth during dl
  $pages{$i} = max($pages{$i},ceil($num/20)+2);
}

# print page 1 for each URL, then page 2, etc
# there might be more efficient ways to do this? (but fast enough for me)

# open(B,">/tmp/testfile.txt");
open(B,"|xargs -r $cmd");

while (%pages) {

  $count++;
  debug("COUNT: $count");

  # print all URLs that still have pages, delete those that dont
  for $i (sort {$a <=> $b} keys %pages) {

    # ignore and delete URLs that have a lower page count
    if ($pages{$i}<$count) {delete $pages{$i}; next;}

    # url for download and output filename (can't use -O will overwrite)
    my($dir,$fname) = ($i, "kinksters?page=$count");
    $dir=~s%^/%%;
    $fname = "$dir/$fname";
    # already exists? keep going
    if (-f $fname) {next;}

    my($url) = "https://fetlife.com/countries/$i/kinksters?page=$count";
    print B "-o '$fname' '$url'\n";
  }
}

close(B);
