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

# <h>sort keys below solely for my OCD</h>
for $i (sort keys %URL) {
  # NOTE: could use parallel here (and for google search above too)
  ($all) = cache_command("curl '$i'","age=86400");

  # break into sections (CMT_ div tags DO nest, but this still works)
  # actually it doesn't but let me checkpoint save before fixing
  while ($all=~s%<div class="CMT_(.*?)>(.*?)</div>%%) {
    ($tag, $content) = ($1, $2);
    debug("TAG: $tag, CONTENT: $content");
  }

#  debug("ALL: $all");
}




