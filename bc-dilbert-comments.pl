#!/bin/perl

# Answers @religiousnut's challenge at http://dilbert.com/strips/comic/2004-02-23/

# <h>I wish I could say that this is the most pointlessly useless
# program I've written, but it's not. Not even in the Top 10,
# really</h>

# In theory, you could expand this program to find all of a given
# user's Dilbert comments <h>... but that would be way too useful</h>

require "bclib.pl";

for $i (1..20) {
  # obtain file (198 total results = hardcode)
  $count = $i*10;
  $url = "http://www.google.com/search?q=site:dilbert.com+jamesdobry&start=$count";
  unless (-f "/tmp/dobry$i.html") {
    # google whines without the -A below
    system("curl -A 'Mozilla... not' -o /tmp/dobry$i.html '$url'");
  }

  # find links (some are google header links)
  $all = read_file("/tmp/dobry$i.html");
  while ($all=~s/<a([^>]*?)>//) {
    $xml = $1;
    $xml=~/href=\"(.*?)\"/;
    $url = $1;
    # ignore non-strip/comment links
    unless ($url=~m%http://(www\.)?dilbert.com/strips/comic%) {next;}

    # makes it easier to avoid dupes
    $URL{$url} = 1;
  }
}

# TODO: Despite hash, URLs may have duplicates because same page may
# have multiple URLs (google may correct for this, not sure)

# <h>sort keys below solely for my OCD</h>
for $i (sort keys %URL) {
  # NOTE: could use parallel here (and for google search above too)
  ($all) = cache_command("curl '$i'","age=86400");

  # find comments
  while ($all=~s%<div class="CMT_CommentList">(.*?)<div class="CMT_Footer">%%s) {
    $cbody = $1;

    # blank hash to store values (and avoid leftovers from previous)
    %hash = ();

    # the user
    $cbody=~s%<div class="CMT_User"><a href="/users/.*?/">(.*?)</a></div>%%s;
    $hash{user} = $1;

    # rating
    $cbody=~s%<div class="CMT_Rating">\s*<span>(.*?)</span>%%s;
    $hash{rating} = $1;

    # date
    $cbody=~s%<div class="CMT_Date">(.*?)</div>%%s;
    $hash{date} = $1;

    # below only works because we remove CMT_Date above
    $cbody=~s%<div class="CMT_Text">\s*(.*?)\s*<div%%s;
    $hash{comment} = $1;

    # ignore non-JamesDobry comments
    unless ($hash{user}=~/jamesdobry/i) {next;}

    # ignore non-"wag" comments
    unless ($hash{comment}=~/w+a+g+/i) {next;}

    print join(",",$hash{date},$hash{rating},$hash{comment})."\n";

  }
}

