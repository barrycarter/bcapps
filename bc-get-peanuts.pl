#!/bin/perl

# Shows how to convert a single Peanuts strip into a Kindle-compatible
# MOBI book

require "/usr/local/lib/bclib.pl";

# data dir
$datadir = "/home/barrycarter/BCGIT/db/";

# arbitrarily chosen date
$date = "1965-01-07";

# split
$date=~/^(\d{4})\-(\d{2})\-(\d{2})$/;
($yr, $mo, $da) = ($1, $2, $3);

# obtain the gocomics "wrapper page" for this comic
unless (-f "$datadir/$date.html") {
  # gocomics appears to need a reasonable looking browser agent
  cache_command("curl -o $datadir/$date.html -A 'Mozilla' -L http://www.gocomics.com/peanuts/$yr/$mo/$da");
}

# find the large version of the image
$data = read_file("$datadir/$date.html");

# look at images
while ($data=~s/(<img[^>]*?>)//is) {
  $img = $1;

  # look for src
  unless ($img=~/src="(.*?)"/) {next;}
  $src = $1;

  # NOTE: there was a way to get the zoomed images (much higher
  # quality), but gocomics appears to have broken this; we can still
  # create Kindle book from the low quality image, but they won't look
  # as good

  # http://cdn.svcs.c2.uclick.com/c2/d77051709863012f2fe400163e41dd5b?width=5000
  # is a 1500 (not 5000) pixel wide copy of one strip, but adding
  # '?width=5000' doesn't work for most images (may work for the very
  # first strip)

  # find the correct image
  unless ($src=~/cdn\.svcs\.c2\.uclick\.com/) {next;}

  # download image and exit this loop


  debug($src);
}



