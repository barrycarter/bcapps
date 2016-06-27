#!/bin/perl

# Extracts a list of people (along w/ their profile links) from pages
# like https://www.quora.com/sitemap/people?page_id=6871 (after
# they've been downloaded)

require "/usr/local/lib/bclib.pl";

# keeps track of which page the user is on, which could be helpful?

for $i (@ARGV) {

  my($num) = $i;
  $num=~s/\D//g;

  my($all) = read_file($i);
  while ($all=~s%/profile/(.*?)\">(.*?)</a>%%) {
    print "$num $1 $2\n";
  }
}
