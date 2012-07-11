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
  unless (-f "$datadir/$date.gif") {
    cache_command("curl -o $datadir/$date.gif -A 'Mozilla' '$src'");
  }
  last;
}

# convert 4-wide to 2x2 for kindle

# split into 4 panels
for $i (0,150,300,450) {
  unless (-f "/tmp/peanuts-$date-$i.gif") {
    cache_command("convert -crop 150x9999+$i+0 -trim -rotate -90 -geometry 300x400\! $datadir/$date.gif /tmp/peanuts-$date-$i.gif");
  }
}

# and stitch back together
unless (-f "/tmp/peanuts-$date-final.gif") {
  cache_command("montage -tile 2x2 -geometry 300x400+0+0 /tmp/peanuts-$date-150.gif /tmp/peanuts-$date-450.gif /tmp/peanuts-$date-0.gif /tmp/peanuts-$date-300.gif /tmp/peanuts-$date-final.gif");
}

# created db/peanut-shell.html by hand

# convert to mobi (I had to do this by hand because of the way my
# mobi2html is installed:

# html2mobi --title "Peanuts Test by Barry Carter (kindletest@barrycarter.info)" --author "Charles Schulz" --gentoc --fixhtmlbr /home/barrycarter/BCGIT/db/peanut-shell.html





