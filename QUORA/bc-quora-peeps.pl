#!/bin/perl

# Extracts a list of people (along w/ their profile links) from pages
# like https://www.quora.com/sitemap/people?page_id=6871 (after
# they've been downloaded)

require "/usr/local/lib/bclib.pl";

while (<>) {
  while (s%/profile/(.*?)\">(.*?)</a>%%) {
    print "$1 $2\n";
  }
}
