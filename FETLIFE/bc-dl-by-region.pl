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

dodie('chdir("/home/barrycarter/FETLIFE/FETLIFE-BY-REGION/$globopts{subdir}")');

my(%files);

# curl commands (lets me change quickly if needed)
my($cmd) = "curl --compress -A 'Fauxzilla' --socks4a 127.0.0.1:9050 -H 'Cookie: _fl_sessionid=$globopts{sessionid}'";

# TODO: add timestamps to everything as we will be on infinite loop(?)

# get list of places
my($out,$err,$res) = cache_command2("$cmd -o ../places.html 'https://fetlife.com/places'","age=86400");
my($data) = read_file("../places.html");

# doing only countries now, and these are countries not listed on
# places.html (because their admin areas are listed instead); this also
# catches handful of people who have no admin areas (probably a
# glitch)
$extra = << "MARK";
<li><a href="/countries/14">Australia</a></li>
<li><a href="/countries/39">Canada</a></li>
<li><a href="/countries/233">USA</a></li>
<li><a href="/countries/247">Bonaire</a></li>
<li><a href="/countries/248">Curacao</a></li>
MARK
;

$data = "$data\n$extra\n";

while ($data=~s%"/(countries)/(\d+)">(.*?)</a>%%) {
  my($type,$num,$name) = ($1,$2,$3);
  my($fname) = "../$type-$num.txt";
  unless (-d "$type/$num") {system("mkdir -p $type/$num");}

  $files{$fname}=1;

  # if we've visited this page less than a day ago, ignore
  if (-f $fname && -M $fname < 1) {next;}

  my($res) = cache_command2("$cmd -o $fname 'https://fetlife.com/$type/$num'");
}

for $i (sort keys %files) {
  my($data) = read_file($i);

  # <h>the abbreviation for country below is in honor of Fetlife</h>
  my($num,$cunt,$url);

  unless ($data=~m%>(.*?) Kinksters living in (.*?)<%) {warn "NO DATA IN: $i";}
  ($num,$cunt) = ($1,$2);

  # print this out just for my ref
#  print "$i\t$cunt\n";

  unless ($data=~m%<a href=\"(.*?)/kinksters\">view more%) {warn "NO URL: $i";}
  my($url) = $1;

  $num=~s/,//g;

  # number of pages for this url
  # some URLs have multiple pages, always choose highest value
  # adding 2 below to allow for growth during dl
  $pages{$url} = max($pages{$url},ceil($num/20)+2);
}

# the output file is now fixed at fetlife-users-0.csv in current
# directory (the "0" indicating this is the unsorted plain version);
# if it exists, we read what pages we've already downloaded to avoid
# repeats

my(%done);

if (-f "fetlife-users-0.csv") {
  open(A,"fetlife-users-0.csv");
  while (<A>) {
    my(@csv)=split(/\,/,$_);

    # if the last field isn't a timestamp, ignore this line, something is wrong
    unless ($csv[-1]=~/^\d+$/) {next;}
    # count how many we have for this page
    $done{$csv[-2]}++;
  }
  close(A);
}

# print page 1 for each URL, then page 2, etc
# there might be more efficient ways to do this? (but fast enough for me)

while (%pages) {

  $count++;

  # print all URLs that still have pages, delete those that dont
  for $i (keys %pages) {

    # ignore and delete URLs that have a lower page count
    if ($pages{$i}<$count) {delete $pages{$i}; next;}

    # url for download and output filename (can't use -O will overwrite)
    my($dir,$fname) = ($i, "kinksters?page=$count");
    $dir=~s%^/%%;
    $fname = "$dir/$fname";
    my($url) = "https://fetlife.com$i/kinksters?page=$count";

    # if file already exists and is nonempty, don't dl
    unless (-f $fname && -s $fname) {

      # get file
      my($out,$err,$res) = cache_command2("$cmd -sS -o '$fname' '$url'");

      # check size
      if (-s $fname < 1000) {xmessage("'$fname'<1000b",1); die;}

    }

    # feed it to bc-parse-user-list, unless already done

    unless ($done{$url}>0) {
      system("/home/barrycarter/BCGIT/FETLIFE/bc-parse-user-list.pl '$fname' >> fetlife-users-0.csv");
    }
  }
}

