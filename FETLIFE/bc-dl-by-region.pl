#!/bin/perl

# Given a list of 1st pages of country/administrative area listings,
# create list of URLs to download data, with first pages of each area
# coming first. In other words, download "best" users for each area
# first.

# major changes 17 May 2015 to localize the process, test for errors,
# allow for mirroring, etc

# $private{fetlife}{session} must be defined in bc-private.pl
# --subdir: the subdirectory to which I am downloading

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# max length of command line (131071 is a guess, leaving room for temp files)
$maxlen = 100000;

defaults("xmessage=1");

unless ($globopts{subdir}) {die("Usage: $0 --subdir=x");}

dodie('chdir("/mnt/extdrive2/FETLIFE-BY-REGION/$globopts{subdir}")');

my(%files);

# curl commands (lets me change quickly if needed)
# -f as crude substitute for checking for 91 byte files
my($cmd) = "curl -f --create-dirs --compress -A Fauxzilla --socks4a 127.0.0.1:9050 -H 'Cookie: _fl_sessionid=$private{fetlife}{session}'";

# get places
my($out, $err, $res) = cache_command2("$cmd https://fetlife.com/places", "age=86400");

my(@cunts);

while ($out=~s%href="/(countries|administrative_areas)/(\d+)"%%s) {
  push(@cunts, "$1/$2");
}

# multi-argument curl is more efficient
open(B,"|xargs -r $cmd");

for $i (@cunts) {
  my($fname) = "$i.txt";
  $fname=~s%/%-%;

  # dont re dl for a given subdir unless too small
  if (-s $fname > 1000) {next;}
  print B "-o $fname https://fetlife.com/$i\n";
}

# we need these files to proceed, so must close and reopen
close(B);

# TODO: add timestamps to everything as we will be on infinite loop(?)

# pages per area

for $i (@cunts) {
  my($fname) = "$i.txt";
  $fname=~s%/%-%;

  my($data) = read_file($fname);

  # <h>the abbreviation for country below is in honor of Fetlife</h>
  my($num,$cunt,$url);

  unless ($data=~m%>(.*?) Kinksters living in (.*?)<%) {warn "NO DATA IN: $i";}
  ($num,$cunt) = ($1,$2);

  unless ($data=~m%<a href=\"(.*?)/kinksters\">view more%) {warn "NO URL: $i";}
  my($url) = $1;

  $num=~s/,//g;

  # number of pages for this url
  # some URLs have multiple pages, always choose highest value
  $pages{$i} = max($pages{$i},ceil($num/20));
}

# print page 1 for each URL, then page 2, etc
# there might be more efficient ways to do this? (but fast enough for me)

# dumping commands to file so I can see results as I run them

# total length so far (start with infinity to force command at start)
my($len) = +Infinity;

open(B,">cmdlist.txt");

# create a 1-command-per-line cmdlist2.txt to avoid throttling
open(C,">cmdlist2.txt");

while (%pages) {

  $count++;

  # print all URLs that still have pages, delete those that dont
  for $i (sort {$a <=> $b} keys %pages) {
    ++$innercount;

    # ignore and delete URLs that have a lower page count
    if ($pages{$i}<$count) {delete $pages{$i}; next;}

    # url for download and output filename (can't use -O will overwrite)
    my($dir,$fname) = ($i, "kinksters?page=$count");
    $dir=~s%^/%%;
    $fname = "$dir/$fname";
    # already exists (and not trivial)? keep going
    if (-s $fname > 1000) {next;}

    # the string to print (if theres room)
    my($str);

    # every so often, visit home page to avoid block
    if ($innercount%25==0) {
      $str .= "-o homepage.html 'https://fetlife.com/home/v4' ";
    }

    my($url) = "https://fetlife.com/$i/kinksters?page=$count";
    $str .= "-o '$fname' '$url' ";

    print C "$cmd -o '$fname' '$url'\n";

    # enough room to print string? (if not, print return first + curl)
    $len += length($str);

    if ($len <= $maxlen) {print B $str; next;}

    # length too long, so print new line
    $str = "\n$cmd $str";
    $len = length($str);
    print B $str;
  }
}

close(B);

die "TESTING";

# now to run the commands
open(B,"cmdlist.txt");

while (<B>) {
  chomp;
  # ignore first line
  if (/^\s*$/) {next;}
  debug("COMMAND START:",time());
  my($out,$err,$res)=cache_command2($_);
  debug("OUT: $out","ERR: $err", "RES: $res");
  debug("COMMAND END:",time());
  # since i repeatedly dl homepage.html, check its size
  # TODO: this only checks once per run, create it many times per run
  unless (-s "homepage.html" > 10000) {die "homepage.html too small";}
  # TODO: check $res, check that files sizes are reasonable, etc
}
